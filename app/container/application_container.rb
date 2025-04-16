# frozen_string_literal: true

require 'dry-container'

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_client, -> { GithubClientStub }
    register :open3, -> { Open3Stub }
    register :payload, ->(params = {}) { PayloadStub.new(params) }
  else
    register :github_client, -> { Octokit::Client }
    register :open3, -> { Open3 }
    register :payload, ->(params = {}) { RealPayload.new(params) }
  end
end
