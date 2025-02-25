# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    GithubWebhookService.add_webhooks_for_user_repos
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
    clone_or_pull_repo(repository_name)

    run_rubocop_check(repository_name)

    render json: { message: 'Webhook processed successfully' }, status: :ok
  end

  def clone_or_pull_repo(repository_name)
    repository = Repository.find_by(name: repository_name)

    repo_dir = Rails.root.join('tmp', 'repos', repository_name)

    if Dir.exist?(repo_dir)
      "cd #{repo_dir} && git pull"
    else
      "git clone https://github.com/#{repository.full_name}/#{repository_name}.git #{repo_dir}"
    end
  end

  def run_rubocop_check(repository_name)
    repo_dir = Rails.root.join('tmp', 'repos', repository_name)

    result = `cd #{repo_dir} && rubocop --config ./.rubocop.yml --format json`

    rubocop_output = JSON.parse(result)

    if rubocop_output.empty?
      Rails.logger.info 'No issues found by RuboCop.'
      { status: :ok, message: 'No issues found' }
    else
      Rails.logger.info "RuboCop issues found:\n#{rubocop_output.to_json}"
      { status: :bad_request, errors: rubocop_output }
    end
  end
end
