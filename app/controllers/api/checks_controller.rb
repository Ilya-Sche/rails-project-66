# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = ApplicationContainer[:payload].call(params).payload

    if payload['commits'].present?
      repository = find_repository
      if repository
        check = Repository::Check.create(repository_id: repository.id)
        Repository::CheckJob.perform_later(check.id)

        render json: { message: 'Webhook processed successfully' }, status: :ok
      else
        render json: { error: 'Repository not found', status: :not_found }
      end
    else
      render json: { error: 'Unsupported event', status: :bad_request }
    end
  end

  private

  def find_repository
    Repository.find_by(github_id: params['repository']['id'])
  end
end
