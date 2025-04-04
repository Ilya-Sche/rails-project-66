# frozen_string_literal: true

class FetchRepositoryDataJob < ApplicationJob
  queue_as :default

  def perform(repository_id, user_id)
    user = User.find(user_id)

    client = ApplicationContainer[:github_client].new(access_token: user.token)

    repo = client.repo

    repository = Repository.find(repository_id)
    if repository.update!(
      name: repo.name,
      full_name: repo.full_name,
      language: repo.language,
      clone_url: repo.clone_url,
      ssh_url: repo.ssh_url
    )
      webhook_service = GithubWebhookService.new(ApplicationContainer[:github_client].new(access_token: current_user.token))
      webhook_service.add_webhook_for_repo(repo.full_name)
      check = Repository::Checks.create

      RepositoryCheckJob.perform_later(check.id)
    end
  end
end
