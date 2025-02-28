# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
OmniAuth.config.test_mode = true

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all
  end

  class ActionDispatch::IntegrationTest
    def sign_in(user, _options = {})
      auth_hash = {
        provider: 'github',
        uid: '12345',
        info: {
          email: user.email,
          name: user.name,
          nickname: user.nickname,
          image: user.image_url
        },
        credentials: {
          token: user.token
        }
      }

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_hash)

      get callback_auth_path('github')
    end

    def signed_in?
      session[:user_id].present? && current_user.present?
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
