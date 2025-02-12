# frozen_string_literal: true

class GithubWebhookService
  def initialize(repository)
    @repository = repository
    @client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end

  def add_webhook
    payload = {
      name: 'web',
      active: true,
      events: ['push'],
      config: {
        url: "#{ENV['BASE_URL']}/api/checks",
        content_type: 'json'
      }
    }

    @client.create_hook(@repository.full_name, payload)
  end
end
