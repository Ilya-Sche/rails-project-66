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
      render json: { error: 'Unsupported event' }, status: :bad_request
    end
  end

  def add_webhook_to_repository(repository)
    webhook_service = GithubWebhookService.new(repository)
    webhook_service.add_webhook
  end

  private

  def process_push_event(payload)
    data = JSON.parse(payload)

    repository_name = data['repository']['name']
    ref = data['ref']
    commits = data['commits']

    @repository = Repository.find_by(name: repository_name)
    run_rubocop_check(repository, commits)

    render json: { message: 'Webhook processed successfully' }, status: :ok
  end

  def run_rubocop_check(repository, commits)
    @repository = Repository.find_by(name: repository_name)

    repo_path = Rails.root.join('tmp', 'repos', @repository.id.to_s)

    unless File.exist?(repo_path)
      `git clone https://github.com/#{@repository.full_name} #{repo_path}`
    end

    Dir.chdir(repo_path) do
      result = `rubocop --format -json`
      rubocop_output = JSON.parse(result)

      if rubocop_output['errors'].empty?
      else
      end
    end
  end
end
