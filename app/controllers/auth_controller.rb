# frozen_string_literal: true

class AuthController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']
    user = find_or_create(auth)

    if user.save
      sign_in(user)
      redirect_to root_path, notice: I18n.t('user.entered')
    else
      redirect_to root_path
    end
  end

  def destroy
    sign_out
    redirect_to root_path, notice: I18n.t('user.logged_out')
  end

  private

  def find_or_create(auth)
    user = User.find_or_initialize_by(email: auth[:info][:email].downcase)
    user.assign_attributes(build_auth_user_params(auth))
    user.save!
    user
  end

  def build_auth_user_params(auth)
    {
      nickname: auth['info']['nickname'],
      name: auth['info']['name'],
      image_url: auth['info']['image'],
      token: auth['credentials']['token']
    }
  end
end
