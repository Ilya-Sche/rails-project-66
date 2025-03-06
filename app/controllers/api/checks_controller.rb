# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = ApplicationContainer[:payload].payload

    event = request.headers['X-GitHub-Event']
    case event
    when 'push'
      process_push_event(payload)
    else
      render json: { error: 'Unsupported event', status: :bad_request }
    end
  end

  private

  def process_push_event(payload)
    data = JSON.parse(payload)

    repository_full_name = data['repository']['full_name']
    user_email = data['pusher']['email']
    data['commits']

    clone_or_pull_repo(repository_full_name)

    run_rubocop_check(repository_full_name, user_email)
    render json: { message: 'Webhook processed successfully' }, status: :ok
    cleanup_repo(repository_full_name)
  end

  def clone_or_pull_repo(repository_full_name)
    repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)

    if Dir.exist?(repo_dir)
      system("cd #{repo_dir} && git pull")
    else
      ApplicationContainer[:git_clone].clone_repo("git clone https://github.com/#{repository_full_name}.git #{repo_dir}")
    end
  end

  def run_rubocop_check(repository_full_name, user_email)
    rubocop = ApplicationContainer[:rubocop].call(repository_full_name)

    rubocop.run_rubocop

    rubocop_output = JSON.parse(rubocop.read_rubocop_report)

    if rubocop_output['files'].any? { |file| file['offenses'].any? }
      send_rubocop_report_to_user(user_email, repository_full_name)
    else
      Rails.logger.info('No offenses found.')
    end
  end

  def send_rubocop_report_to_user(user_email, repository_full_name)
    ApplicationContainer[:send_report].call(repository_full_name).send_rubocop_report(repository_full_name, user_email)
  end

  def cleanup_repo(repository_full_name)
    repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)
    FileUtils.rm_rf(repo_dir)
  end
end
