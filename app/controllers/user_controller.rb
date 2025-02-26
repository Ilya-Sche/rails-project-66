# frozen_string_literal: true

class UserController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def create
    @user = User.find_or_create_by(email: user_params[:email]) do |u|
      u.name = user_params[:name]
    end

    if @user.persisted?
      session[:user_id] = @user.id
      redirect_to profile_path, notice: I18n.t('user.entered')
    else
      redirect_to root_path, alert: I18n.t('user.auth')
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def authenticate_user!
    redirect_to root_path, alert: I18n.t('user.auth') unless user_signed_in?
  end
end
