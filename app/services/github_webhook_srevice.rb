# frozen_string_literal: true

class GithubWebhookService
  def initialize(repository)
    @repository = repository
    @client = Octokit::Client.new(access_token: current_user.token)
  end

  def add_webhook
    config = {
      url: 'https://1a54-195-54-33-188.ngrok-free.app/api/checks',
      content_type: 'json'
    }

    options = {
      events: ['push'],
      active: true
    }

    @client.create_hook(@repository.full_name, 'web', config, options)
  end
end
