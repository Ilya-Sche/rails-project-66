# frozen_string_literal: true

class GithubWebhookService
  def add_webhooks_for_user_repos
    @client = Octokit::Client.new(current_user)
    repos = @client.repos(user.nickname)
    repos.each do |repo|
      puts "Проверка репозитория: #{repo.name}"

      if webhook_exists?(repo)
        puts "Webhook для репозитория #{repo.name} уже существует."
      else
        puts "Создание вебхука для репозитория #{repo.name}..."
        add_webhook(repo)
      end
    end
  end

  private

  def check_webhook(repo)
    hooks = @client.hooks(repo.full_name)

    webhook_exists = hooks.any? do |hook|
      hook.config['url'] == 'https://9e00-195-54-33-188.ngrok-free.app/api/checks'
    end

    if webhook_exists
      puts "Webhook для репозитория #{repo.full_name} существует."
    else
      puts "Webhook для репозитория #{repo.full_name} не найден."
    end
  end

  def webhook_exists?(repo)
    hooks = @client.hooks(repo.full_name)

    hooks.any? { |hook| hook.config['url'] == 'https://9e00-195-54-33-188.ngrok-free.app/api/checks' }
  end

  def add_webhook(repo)
    name = 'web'
    config = {
      url: 'https://9e00-195-54-33-188.ngrok-free.app/api/checks',
      content_type: 'json'
    }

    options = {
      events: ['push'],
      active: true
    }

    @client.create_hook(repo.full_name, name, config, options)
  end
end
