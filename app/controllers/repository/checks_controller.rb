# frozen_string_literal: true

require 'open3'

class Repository::ChecksController < ApplicationController
  before_action :authenticate_user!
  def show
    @repository = Repository.owner(current_user).find(params[:repository_id])
    @check = @repository.checks.find(params[:id])
    authorize @check
  end

  def create
    @repository = Repository.find(params[:repository_id])
    @check = @repository.checks.new

    if @check.save
      redirect_to repository_path(@repository), notice: I18n.t('check.created')
      RepositoryCheckJob.perform_now(@check.id, @repository.id)
    else
      redirect_to repository_path(@repository), alert: I18n.t('check.error')
    end
  end

  private

  def authenticate_user!
    redirect_to root_path, alert: I18n.t('user.auth') unless current_user
  end
end
