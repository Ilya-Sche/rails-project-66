# frozen_string_literal: true

class CheckRepositoryJob < ApplicationJob
  queue_as :default

  def perform(repository, user_email)
    repository_full_name = repository.full_name

    # clone_or_pull_repo(repository_full_name)
    run_rubocop_check(repository_full_name, user_email)
    cleanup_repo(repository_full_name)
  end

  private

  # def clone_or_pull_repo(repository_full_name)
  #   repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)

  #   if Dir.exist?(repo_dir)
  #     system("cd #{repo_dir} && git pull")
  #   else
  #     ApplicationContainer[:git_clone].clone_repo("git clone https://github.com/#{repository_full_name}.git #{repo_dir}")
  #   end
  # end

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
