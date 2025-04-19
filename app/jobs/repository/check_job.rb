# frozen_string_literal: true

class Repository::CheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    Rails.logger.info("Starting Repository::CheckJob for check_id=#{check_id}")
    @check = Repository::Check.find(check_id)
    @repository = @check.repository

    begin
      Rails.logger.info("Fetching commit for repository #{@repository.full_name}")
      commit_id = fetch_commit(@repository)

      start_linter_check(commit_id)
    rescue StandardError => e
      Rails.logger.error("Error in Repository::CheckJob: #{e.message}")
      Rails.logger.error("Backtrace: #{e.backtrace}")

      @check.fail_check
      @check.update(passed: false)
    end

    Rails.logger.info('Sending linter report to user')
    send_linter_report_to_user(@repository, @check)
    Rails.logger.info("Finished Repository::CheckJob for check_id=#{check_id}")
  end

  def fetch_commit(repository)
    Rails.logger.info('Initializing GitHub client')
    client = ApplicationContainer[:github_client].new(access_token: repository.user.token)

    Rails.logger.info("Fetching commits for #{repository.full_name}")
    commits = client.commits(repository.full_name)
    sha = commits.last.sha
    Rails.logger.info("Latest commit SHA: #{sha}")
    sha
  end

  def start_linter_check(commit_id)
    Rails.logger.info("Starting linter check for commit_id=#{commit_id}")
    @check.start_check
    @check.update(commit_id:)

    repo_path = clone_repo

    language = @repository.language
    Rails.logger.info("Detected language: #{language}")

    if language == 'Ruby'
      run_rubocop(repo_path)
    else
      run_eslint(repo_path)
    end

    cleanup_repo(repo_path)

    @check.complete_check

    passed = @check.linter_errors.empty?
    Rails.logger.info("Linter check completed. Passed: #{passed}")
    @check.update(passed:)
  end

  def clone_repo
    repo_path = Rails.root.join('tmp', 'repos', @repository.full_name)
    Rails.logger.info("Cloning repository to #{repo_path}")
    stdout, stderr, status = ApplicationContainer[:open3].capture3("git clone #{@repository.clone_url} #{repo_path}")
    Rails.logger.info("Git clone stdout: #{stdout}")
    Rails.logger.error("Git clone stderr: #{stderr}") unless status.success?
    repo_path
  end

  def run_rubocop(repo_path)
    Rails.logger.info("Running RuboCop on #{repo_path}")
    stdout, stderr = ApplicationContainer[:open3].capture3("rubocop --config ./.rubocop.yml --format json #{repo_path}")
    Rails.logger.info("RuboCop output: #{stdout}")
    Rails.logger.error("RuboCop error: #{stderr}") if stderr.present?

    @errors = parse_rubocop_output(stdout)
    Rails.logger.info("Parsed RuboCop errors: #{@errors.size} issues found")

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

    json_output = JSON.parse(stdout)
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
    Rails.logger.info("Running ESLint on #{repo_path}")
    command = "node_modules/eslint/bin/eslint.js #{repo_path} --format json --config .eslintrc.json --no-eslintrc"
    stdout, stderr = ApplicationContainer[:open3].capture3("sh -c '#{command}'")
    Rails.logger.info("ESLint output: #{stdout}")
    Rails.logger.error("ESLint error: #{stderr}") if stderr.present?

    JSON.parse(stdout).each do |file|
      next unless file['messages'].any?

      file['messages'].each do |message|
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
    Rails.logger.info("Sending report email to #{repository.user.email}")
    repository_id = repository.id
    check_id = check.id
    user_email = repository.user.email
    RubocopMailer.send_rubocop_report(user_email, repository_id, check_id).deliver_now
    Rails.logger.info('Report email sent')
  end

  def cleanup_repo(repo_path)
    Rails.logger.info("Cleaning up repo at #{repo_path}")
    FileUtils.rm_rf(repo_path)
  end
end
