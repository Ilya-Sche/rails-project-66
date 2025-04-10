# frozen_string_literal: true

require 'open3'

class Web::Repository::ChecksController < ApplicationController
  before_action :authenticate_user!
  def show
    @repository = current_user.repositories.find(params[:repository_id])
    @check = @repository.checks.find(params[:id])
  end

  def create
    @repository = current_user.repositories.find(params[:repository_id])
    @check = @repository.checks.new

    if @check.save
      redirect_to repository_path(@repository), notice: I18n.t('check.created')
      Repository::CheckJob.perform_later(@check.id)
    else
      redirect_to repository_path(@repository), alert: I18n.t('check.error')
    end
  end
end
