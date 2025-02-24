# frozen_string_literal: true

class GithubWebhookService
  def initialize(user)
    @user = user
    @client = Octokit::Client.new(access_token: @user.token)
  end

  def add_webhooks_for_user_repos
    repos = @client.repos(@user.nickname)
    debugger
    repos.each do |repo|
      add_webhook(repo)
    end
  end

  private

  def add_webhook(repo)
    name = 'web'
    config = {
      url: 'https://fa62-195-54-33-188.ngrok-free.app/api/checks',
      content_type: 'json'
    }

    options = {
      events: ['push'],
      active: true
    }

    @client.create_hook(repo.full_name, name, config, options)
  end
end
