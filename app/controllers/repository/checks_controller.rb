# frozen_string_literal: true

require 'open3'

class Repository::ChecksController < ApplicationController

  def show
    @repository = Repository.find(params[:repository_id])
    @check = @repository.checks.find(params[:id])
  end

  def create
    @repository = Repository.find(params[:repository_id])

    @check = @repository.checks.new(commit_id: fetch_latest_commit)

    language = fetch_repository_language

    if @check.save
      redirect_to repository_checks_path(@repository), notice: 'Проверка успешно создана!'
      start_rubocop_check_in_background(language)
    else
      redirect_to repository_checks_path(@repository), alert: 'Не удалось создать проверку.'
    end
  end

  private

  def fetch_repository_language
    client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    repo = client.repo(@repository.full_name)
    repo.language
  end

  def fetch_latest_commit
    client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    commits = client.commits(@repository.full_name)
    commits.last.sha
  end

  def start_rubocop_check_in_background(language)
    Thread.new do
      begin
        @check.update(status: :in_progress)
        clone_repo
          if language == 'Ruby'
            run_rubocop
          else language == 'JavaScript'
            run_eslint
          end

          if @check.errors.any?
            @check.update(status: 'failed', passed: false)
          else
            @check.update(status: 'completed', passed: true)
          end

      rescue StandardError => e
        Rails.logger.error "Ошибка при проверке репозитория: #{e.message}"
        @check.update(status: 'failed', passed: false)
      end
    end
  end

  def clone_repo
    clone_dir = Rails.root.join('tmp', 'repos', @repository.id.to_s)
    FileUtils.rm_rf(clone_dir)
    system("git clone https://github.com/#{@repository.full_name}.git #{clone_dir}")
  end

  def run_rubocop
    repo_path = Rails.root.join('tmp', 'repos', @repository.id.to_s)

    stdout, stderr, status = Open3.capture3("rubocop #{repo_path}")

    Rails.logger.info "Результат RuboCop:\n#{stdout}"
    Rails.logger.error "Ошибки RuboCop:\n#{stderr}" if stderr.present?

    @errors = parse_rubocop_output(stdout)
    @errors.each do |error|
      @check.rubocop_errors.create(
        file: error[:file],
        line: error[:line],
        offense_code: error[:offense_code], 
        message: error[:message],
        column: error[:column]
      )
    end
  end

  def parse_rubocop_output(stdout)
    @errors = []
  
    stdout.each_line do |line|
      if match = line.match(/^(.*):(\d+):(\d+):\s*(C:\s*)?\[(Correctable)\]\s*(.*?):\s*(.*)/)
        file = match[1]
        line = match[2]
        column = match[3]
        offense_code = match[6]
        message = match[7] 
  
        @errors << { file: , line: , message: , offense_code: , column: }
      end
    end
  
    @errors
  end

  def run_eslint
    @errors = []

    repo_path = Rails.root.join('app', 'tmp', 'repos', '1')
  
    command = "node_modules/eslint/bin/eslint.js #{repo_path} --format=json --config ./.eslintrc.yml  --no-eslintrc"
  
    stdout, stderr, status = Open3.capture3("sh -c '#{command}'")
    Rails.logger.info "Результат ESLint:\n#{stdout}"
    Rails.logger.error "Ошибки ESLint:\n#{stderr}" if stderr.present?

    @errors = parse_eslint_output(stdout)
    @errors.each do |error|
      check.rubocop_errors.create(
        file: error[:file],
        line: error[:line],
        offense_code: error[:offense_code],
        message: error[:message]
      )
      @errors << { file: , line: , message: , offense_code: , column: }
    end
    @errors
  end

  def parse_eslint_output(stdout)
    JSON.parse(stdout).map do |error|
      {
        file: error['filePath'],
        line: error['line'],
        offense_code: error['ruleId'],
        message: error['message']
      }
    end
  end

  def check_params
    params.require(:repository_check).permit(:commit_id)
  end
end