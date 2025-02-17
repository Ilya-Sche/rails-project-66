# frozen_string_literal: true

class GithubWebhookService
  def initialize(repository)
    @repository = repository
    @client = Octokit::Client.new(access_token: current_user.token)
  end

  def add_webhook
    payload = {
      name: 'web',
      active: true,
      events: ['push'],
      config: {
        url: 'https://1a54-195-54-33-188.ngrok-free.app/checks',
        content_type: 'json'
      }
    }

    @client.create_hook(@repository.full_name, payload)
  end
end
