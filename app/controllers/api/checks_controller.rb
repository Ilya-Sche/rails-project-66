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
    result = `rubocop --config ./.rubocop.yml --format json`
    rubocop_output = JSON.parse(result)

    return { status: :ok, message: 'No issues found' } if rubocop_output.empty?

    formatted_output = rubocop_output.each_line do |line|
    end.join("\n\n")

    Rails.logger.info("RuboCop output:\n#{formatted_output}")

    { status: :bad_request, errors: formatted_output } if formatted_output?
  end
end
