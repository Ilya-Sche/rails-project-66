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

    Rails.logger.info("RuboCop output: #{result}")

    rubocop_output = JSON.parse(result)

    if rubocop_output.empty?
      { status: :ok, message: 'No issues found' }
    else
      formatted_errors = rubocop_output.map do |file|
        {
          file: file['filename'],
          offenses: file['offenses'].map { |offense| "#{offense['message']} (Line: #{offense['location']['start_line']})" }
        }
      end
      { status: :bad_request, errors: formatted_errors }
    end
  end
end
