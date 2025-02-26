# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include AuthManager
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :user_signed_in?, :current_user
end
