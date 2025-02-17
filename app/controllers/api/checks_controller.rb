# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = request.body.read

    event = request.headers['X-GitHub-Event']
    case event
    when 'push'
      process_push_event(payload)
    else
      { error: 'Unsupported event', status: :bad_request }
    end
  end

  def add_webhooks_to_existing_repositories
    Repository.all.each do |repository|
      webhook_service = GithubWebhookService.new(repository)
      webhook_service.add_webhook
    end
  end

  private

  def process_push_event(payload)
    data = JSON.parse(payload)

    repository_name = data['repository']['name']
    commits = data['commits']

    repository = Repository.find_by(name: repository_name)

    run_rubocop_check(repository, commits)

    { message: 'Webhook processed successfully', status: :ok }
  end

  def run_rubocop_check(repository, commits)
    result = `rubocop --format json`
    rubocop_output = JSON.parse(result)

    if rubocop_output.empty?
      { status: :ok }
    else
      { status: :bad_request, errors: rubocop_output }
    end
  end
end
