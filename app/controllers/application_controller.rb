# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include AuthManager
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :user_signed_in?, :current_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = t('user.not_performed')
    redirect_to root_path
  end

  def authenticate_user!
    redirect_to root_path, alert: I18n.t('user.auth') unless current_user
  end
end
