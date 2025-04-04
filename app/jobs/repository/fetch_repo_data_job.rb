# frozen_string_literal: true

class Repository::FetchDataJob < ApplicationJob
  queue_as :default

  def perform(repository_id, user_id)
    user = User.find(user_id)

    client = ApplicationContainer[:github_client].new(access_token: user.token)

    repo = client.repo(repository_id)

    repository = Repository.find_by(github_id: repository_id)
    attrs = repo.to_h.slice(:name, :full_name, :language, :clone_url, :ssh_url)
    if repository.update(attrs)
      webhook_service = GithubWebhookService.new(client)
      webhook_service.add_webhook_for_repo(repo.full_name)
      check = Repository::Check.create(repository_id: repository.id)

      Repository::CheckJob.perform_later(check.id)
    else
      Rails.logger.error(repository.errors.full_messages)
    end
  end
end
