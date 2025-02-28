# frozen_string_literal: true

require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  test 'check github auth' do
    post auth_request_path('github')
    assert_response :redirect
  end

  test 'create' do
    auth_hash = {
      provider: 'github',
      uid: '12345',
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.first_name,
        nickname: Faker::Name.first_name,
        image_ulr: Faker::Internet.email
      },
      credentials: {
        token: Faker::Internet.uuid
      }
    }

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(auth_hash)

    get callback_auth_path('github')
    assert_response :redirect

    user = User.find_by(email: auth_hash[:info][:email].downcase)

    assert user
    assert signed_in?
  end

  test 'logout' do
    user = users(:one)
    sign_in user

    get logout_path
    assert_response :redirect
    assert user_signed_in?: false
  end
end
