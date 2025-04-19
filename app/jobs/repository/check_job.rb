# frozen_string_literal: true

class Repository::CheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    @check = Repository::Check.find(check_id)
    @repository = @check.repository

    begin
      commit_id = fetch_commit(@repository)

      start_linter_check(commit_id)
    rescue StandardError => e
      @check.fail_check
      @check.update(passed: false)

      Rails.logger.error("Error in Repository::CheckJob: #{e.message}")
      Rails.logger.error("Backtrace: #{e.backtrace}")
    end
    send_linter_report_to_user(@repository, @check)
  end

  def fetch_commit(repository)
    client = ApplicationContainer[:github_client].new(access_token: repository.user.token)
    commits = client.commits(repository.full_name)
    commits.last.sha
  end

  def start_linter_check(commit_id)
    @check.start_check
    @check.update(commit_id:)
    repo_path = clone_repo

    language = @repository.language
    if language == 'Ruby'
      run_rubocop(repo_path)
    else
      run_eslint(repo_path)
    end

    cleanup_repo(repo_path)

    @check.complete_check

    if @check.linter_errors.empty?
      @check.update(passed: true)
    else
      @check.update(passed: false)
    end
  end

  def clone_repo
    repo_path = Rails.root.join('tmp', 'repos', @repository.full_name)

    ApplicationContainer[:open3].capture3("git clone #{@repository.clone_url} #{repo_path}")
    repo_path
  end

  def run_rubocop(repo_path)
    stdout, _stderr = ApplicationContainer[:open3].capture3("rubocop --config ./.rubocop.yml --format json #{repo_path}")

    @errors = parse_rubocop_output(stdout)
    @errors.each do |error|
      @check.linter_errors.create(
        file: error[:file],
        line: error[:line],
        offense_code: error[:offense_code],
        message: error[:message],
        column: error[:column]
      )
    end
  end

  def parse_rubocop_output(stdout)
    Rails.logger.info('Parsing RuboCop JSON output')
    @errors = []

    begin
      json_output = JSON.parse(stdout)
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse RuboCop output: #{e.message}")
      Rails.logger.error("Raw RuboCop stdout: #{stdout.inspect}")
      raise
    end

    json_output['files'].each do |file|
      file['offenses'].each do |offense|
        @errors << {
          file: file['path'],
          line: offense['location']['start_line'],
          column: offense['location']['start_column'],
          offense_code: offense['cop_name'],
          message: offense['message']
        }
      end
    end
    @errors
  end

  def run_eslint(repo_path)
    command = "node_modules/eslint/bin/eslint.js #{repo_path} --format json --config .eslintrc.json --no-eslintrc"
    stdout, _stderr = ApplicationContainer[:open3].capture3("sh -c '#{command}'")

    JSON.parse(stdout).flat_map do |file|
      next unless file['messages'].any?

      file['messages'].map do |message|
        error = {
          file: file['filePath'],
          line: message['line'],
          column: message['column'],
          offense_code: message['ruleId'],
          message: message['message']
        }

        @check.linter_errors.create(error)
      end
    end
  end

  def send_linter_report_to_user(repository, check)
    repository_id = repository.id
    check_id = check.id
    user_email = repository.user.email
    RubocopMailer.send_rubocop_report(user_email, repository_id, check_id).deliver_now
  end

  def cleanup_repo(repo_path)
    FileUtils.rm_rf(repo_path)
  end
end
