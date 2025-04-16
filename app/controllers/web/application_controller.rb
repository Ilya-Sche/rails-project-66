# frozen_string_literal: true

class Web::ApplicationController < ApplicationController
  include AuthManager

  helper_method :user_signed_in?, :current_user

  private

  def user_not_authorized
    flash[:alert] = t('user.not_performed')
    redirect_to root_path
  end

  def authenticate_user!
    redirect_to root_path, alert: I18n.t('user.auth') unless current_user
  end
end
