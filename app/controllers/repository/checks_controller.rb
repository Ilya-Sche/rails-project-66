# frozen_string_literal: true

require 'open3'

class Repository::ChecksController < ApplicationController
  def show
    @repository = Repository.find(params[:repository_id])
    @check = @repository.checks.find(params[:id])
  end

  def create
    @repository = Repository.find(params[:repository_id])
    @check = @repository.checks.new(commit_id: fetch_commit)
    language = @repository.language

    if @check.save
      redirect_to repository_path(@repository), notice: I18n.t('check.created')
      start_rubocop_check_in_background(language)
    else
      redirect_to repository_path(@repository), alert: I18n.t('check.error')
    end
  end

  private

  def fetch_commit
    client = Octokit::Client.new(access_token: current_user.token)
    commits = client.commits(@repository.full_name)
    commits.last.sha
  end

  def start_rubocop_check_in_background(language)
    @check.update(status: :in_progress)
    clone_repo
    if language == 'Ruby'
      run_rubocop
    else
      run_eslint
    end

    cleanup_repo

    if @check.rubocop_errors.empty?
      @check.update(status: 'completed', passed: true)
    else
      @check.update(status: 'failed', passed: false)
    end
  end

  def clone_repo
    clone_dir = Rails.root.join('tmp', 'repos', @repository.full_name)
    system("git clone https://github.com/#{@repository.full_name}.git #{clone_dir}")
  end

  def run_rubocop
    repo_path = Rails.root.join('tmp', 'repos', @repository.full_name)
    stdout, _stderr = Open3.capture3("rubocop --config ./.rubocop.yml #{repo_path}")

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
      next unless (match = line.match(/^(.*):(\d+):(\d+):\s*(C:\s*)?\[(Correctable)\]\s*(.*?):\s*(.*)/))

      file = match[1]
      line = match[2]
      column = match[3]
      offense_code = match[6]
      message = match[7]

      @errors << { file:, line:, message:, offense_code:, column: }
    end
    @errors
  end

  def run_eslint
    @errors = []

    repo_path = Rails.root.join('app/tmp/repos/1')
    command = "node_modules/eslint/bin/eslint.js #{repo_path} --format=json --config ./.eslintrc.yml  --no-eslintrc"
    stdout, _stderr = Open3.capture3("sh -c '#{command}'")

    @errors = parse_eslint_output(stdout)
    @errors.each do |error|
      check.rubocop_errors.create(
        file: error[:file],
        line: error[:line],
        offense_code: error[:offense_code],
        message: error[:message]
      )
      @errors << { file:, line:, message:, offense_code:, column: }
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

  def cleanup_repo
    clone_dir = Rails.root.join('tmp', 'repos', @repository.full_name)
    FileUtils.rm_rf(clone_dir)
  end
end
