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

    @errors = rubocop_output
    @errors.each do |error|
      @check.rubocop_errors.create(
        file: error[:file],
        line: error[:line],
        offense_code: error[:offense_code],
        message: error[:message],
        column: error[:column]
      )
    end

    { status: :bad_request, errors: @errors } if @errors.any?
  end
end
