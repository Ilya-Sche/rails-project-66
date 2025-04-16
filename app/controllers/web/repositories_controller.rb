# frozen_string_literal: true

class Web::RepositoriesController < Web::ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories
  end

  def show
    @repository = current_user.repositories.find(params[:id])

    @checks = @repository.checks.order(created_at: :desc).limit(15)
  end

  def new
    client = ApplicationContainer[:github_client].new(access_token: current_user.token, auto_paginate: true)
    all_repositories = client.repos
    languages = Repository.language.values

    @repositories = all_repositories.select { |repo| languages.include?(repo.language) }
  end

  def create
    github_id = params[:repository][:github_id].to_i
    if Repository.exists?(github_id:)
      redirect_to repositories_path, alert: I18n.t('repository.exists')
    else
      current_user.repositories.create(github_id:)
      Repository::FetchDataJob.perform_later(github_id)
      redirect_to repositories_path, notice: I18n.t('repository.created')
    end
  end
end
