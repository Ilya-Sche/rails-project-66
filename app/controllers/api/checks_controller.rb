# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = ApplicationContainer[:payload].call(params).payload
    if payload['commits'].present?
      process_push_event(payload)
    else
      render json: { error: 'Unsupported event', status: :bad_request }
    end
  end

  private

  def process_push_event(payload)
    data = JSON.parse(payload)

    repository_full_name = data['repository']['full_name']
    user_email = data['pusher']['email']
    repository_id = data['repository']['id']

    repository = find_repository(repository_id, repository_full_name)
    if repository
      CheckRepositoryJob.perform_later(repository, user_email)

      render json: { message: 'Webhook processed successfully' }, status: :ok
    else
      render json: { error: 'Repository not found', status: :not_found }
    end
  end

  def find_repository(repository_id, repository_full_name)
    Repository.find_by(github_id: repository_id) || Repository.find_by(full_name: repository_full_name)
  end
end
