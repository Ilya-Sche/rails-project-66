# frozen_string_literal: true

class GithubWebhookService
  def initialize(client)
    @client = client
  end

  def add_webhook_for_repo(repo_full_name)
    @repository = Repository.find_or_create_by(full_name: repo_full_name)

    if webhook_exists?(@repository.full_name)
      return
    end

    add_webhook(repo_full_name)
  end

  private

  def add_webhook(repo_full_name)
    name = 'web'
    config = {
      url: 'https://ec5e-195-54-33-188.ngrok-free.app/api/checks',
      content_type: 'json'
    }

    options = {
      events: ['push'],
      active: true
    }

    @client.create_hook(repo_full_name, name, config, options)
  end

  def webhook_exists?(repo_full_name)
    hooks = @client.hooks(repo_full_name)
    hooks.any? { |hook| hook['config']['url'] == 'https://ec5e-195-54-33-188.ngrok-free.app/api/checks' }
  end
end
