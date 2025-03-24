# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories
  end

  def show
    @repository = Repository.owner(current_user).find(params[:id])
    authorize @repository

    @checks = @repository.checks.order(created_at: :desc).limit(15)
  end

  def new
    client = ApplicationContainer[:github_client].new(access_token: current_user.token, auto_paginate: true)
    @repositories = client.repos
  end

  def create
    client = ApplicationContainer[:github_client].new access_token: current_user.token
    repo = client.repo(params[:repository][:github_id].to_i)
    webhook_service = GithubWebhookService.new(ApplicationContainer[:github_client].new(access_token: current_user.token))
    existing_repo = current_user.repositories.find_by(github_id: repo.id) || current_user.repositories.find_by(full_name: repo.full_name)

    if existing_repo
      redirect_to repositories_path, alert: I18n.t('repository.exists')
    else
      @repository = current_user.repositories.new(
        name: repo.name,
        github_id: repo.id,
        full_name: repo.full_name,
        language: repo.language,
        clone_url: repo.clone_url,
        ssh_url: repo.ssh_url
      )
      if @repository.save
        webhook_service.add_webhook_for_repo(@repository.full_name)
        check = @repository.checks.create

        RepositoryCheckJob.perform_later(check.id, @repository.id)
        redirect_to repositories_path, notice: I18n.t('repository.created')
      else
        redirect_to new_repository_path, alert: I18n.t('repository.error')
      end
    end
  end

  private

  def authenticate_user!
    redirect_to root_path, alert: I18n.t('user.auth') unless current_user
  end
end
