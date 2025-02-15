# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @repository = Repository.find(params[:repository_id])

    @api_check = @repository.api_checks.new(commit_id: fetch_latest_commit)
  end

  def webhook
    payload = request.body.read

    event = request.headers['X-GitHub-Event']
    case event
    when 'push'
      process_push_event(payload)
    else
      render json: { error: 'Unsupported event' }, status: :bad_request
    end
  end

  def add_webhook_to_repository(repository)
    webhook_service = GithubWebhookService.new(repository)
    webhook_service.add_webhook
  end

  private

  def fetch_latest_commit
    client = Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN', nil))
    commits = client.commits(@repository.full_name)
    commits.last.sha
  end

  def process_push_event(payload)
    data = JSON.parse(payload)

    repository = data['repository']['name']
    ref = data['ref']
    commits = data['commits']

    run_rubocop_check(repository, commits)

    render json: { message: 'Webhook processed successfully' }, status: :ok
  end

  def run_rubocop_check(repository, commits)
    @api_check.update(status: :in_progress)

    result = `rubocop --format json`
    rubocop_output = JSON.parse(result)

    @errors = rubocop_output.each do |error|
      @api_check.rubocop_errors.create
    end

    if @api_check.errors.any?
      @api_check.update(status: 'failed', passed: false)
    else
      @api_check.update(status: 'completed', passed: true)
    end
  end
end
