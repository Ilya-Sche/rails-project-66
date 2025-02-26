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
      system("git clone https://github.com/#{repository_full_name}.git #{repo_dir}")
    end
  end

  def run_rubocop_check(repository_full_name, user_email)
    repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)

    rubocop_config_path = Rails.root.join('.rubocop.yml')

    `cd #{repo_dir} && rubocop --config #{rubocop_config_path} --format json --out #{repo_dir}/rubocop_report.json`

    rubocop_output = JSON.parse(File.read("#{repo_dir}/rubocop_report.json"))

    if rubocop_output['files'].any? { |file| file['offenses'].any? }
      send_rubocop_report_to_user(user_email, repository_full_name)
    else
      Rails.logger.info('No offenses found.')
    end
  end

  def send_rubocop_report_to_user(user_email, repository_full_name)
    repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)
    file_path = Rails.root.join("#{repo_dir}/rubocop_report.json")

    RubocopMailer.send_rubocop_report(user_email, file_path).deliver_now
  end

  def cleanup_repo(repository_full_name)
    repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)
    FileUtils.rm_rf(repo_dir)
  end
end
