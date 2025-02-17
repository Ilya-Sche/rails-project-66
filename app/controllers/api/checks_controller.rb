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

  private

  def process_push_event(payload)
    data = JSON.parse(payload)

    repository_name = data['repository']['name']
    commits = data['commits']

    repository = Repository.find_by(name: repository_name)

    if repository
      result = run_rubocop_check(repository, commits)

      if result[:status] == :ok
        render json: { message: 'Webhook processed successfully' }, status: :ok
      else
        render json: { error: 'RuboCop check failed', details: result[:errors] }, status: :bad_request
      end
    else
      render json: { error: 'Repository not found' }, status: :not_found
    end
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
