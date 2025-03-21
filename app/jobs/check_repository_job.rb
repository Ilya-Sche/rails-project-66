# frozen_string_literal: true

class CheckRepositoryJob < ApplicationJob
  queue_as :default

  def perform(repository, user_email, commit_id)
    run_rubocop_check(repository, user_email, commit_id)
    cleanup_repo(repository.full_name)
  end

  private

  def create_repository_check!(commit_id, repository_id)
    @repository_check = Repository::Check.new(commit_id:, repository_id:)
    @repository_check.save!
  end

  def run_rubocop_check(repository, user_email, commit_id)
    repository_full_name = repository.full_name
    create_repository_check!(commit_id, repository.id)

    rubocop = ApplicationContainer[:rubocop].call(repository_full_name)
    rubocop.run_rubocop
    @repository_check.update(aasm_state: :checking)
    rubocop_output = JSON.parse(rubocop.read_rubocop_report)

    if rubocop_output['files'].any? { |file| file['offenses'].any? }
      @repository_check.update(aasm_state: 'finished', passed: false)
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
