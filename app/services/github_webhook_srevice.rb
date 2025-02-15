# frozen_string_literal: true

class GithubWebhookService
  def add_webhook
    payload = {
      name: 'web',
      active: true,
      events: ['push'],
      config: {
        url: "#{ENV.fetch('BASE_URL')}/api/checks",
        content_type: 'json'
      }
    }

    @client.create_hook(@repository.full_name, payload)
  end
end
