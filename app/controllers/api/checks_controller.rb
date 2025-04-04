# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = params

    if payload['commits'].present?
      user_email = payload['pusher']['email']
      commit_id = payload['commits'].last['sha']
      repository = find_repository
      if repository
        ApiCheckRepositoryJob.perform_later(repository, user_email, commit_id)

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
