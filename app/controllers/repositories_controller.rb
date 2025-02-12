# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories
  end

  def show
    @repository = Repository.find(params[:id])
    @checks = @repository.checks.order(created_at: :desc).limit(5)
  end

  def new
    client = Octokit::Client.new(access_token: current_user.token, auto_paginate: true)
    debugger
    @repositories = client.repos
  end

  def create
    client = Octokit::Client.new access_token: current_user.token
    repo = client.repo(params[:repo_id])

    @repository = current_user.repositories.new(
      name: repo.name,
      github_id: repo.id,
      full_name: repo.full_name,
      language: repo.language,
      clone_url: repo.clone_url,
      ssh_url: repo.ssh_url
    )
    if @repository.save
      redirect_to repositories_path, notice: 'Репозиторий успешно добавлен'
    else
      redirect_to new_repository_path, alert: 'Ошибка при добавлении репозитория'
    end
  end

  private

  def authenticate_user!
    redirect_to root_path, alert: I18n.t('user.auth') unless current_user
  end
end
