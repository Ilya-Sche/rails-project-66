# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  include GithubWebhookService
  skip_before_action :verify_authenticity_token

  def webhook
    payload = request.body.read

    event = request.headers['X-GitHub-Event']

    case event
    when 'push'
      service = GithubWebhookService.new(payload)

      begin
        result = service.process_push_event

        if result[:status] == :ok
          render json: { message: 'Webhook processed successfully' }, status: :ok
        else
          render json: { error: 'Failed to process webhook', details: result[:errors] }, status: :bad_request
        end
      rescue StandardError => e
        render json: { error: "Error processing webhook: #{e.message}" }, status: :internal_server_error
      end
    else
      render json: { error: 'Unsupported event' }, status: :bad_request
    end
  end

  private

  def process_push_event(payload)
    data = JSON.parse(payload)

    repository_name = data['repository']['name']
    commits = data['commits']

    repository = Repository.find_by(name: repository_name)

    run_rubocop_check(repository, commits)

    render json: { message: 'Webhook processed successfully' }, status: :ok
  end

  def run_rubocop_check(repository, commits)
    result = `rubocop --format json`
    rubocop_output = JSON.parse(result)

    if rubocop_output.empty?
      render json:, status: :ok
    else
      render json:, status: :bad_request, errors: rubocop_output
    end
  end
end
