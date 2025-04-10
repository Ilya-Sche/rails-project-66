# frozen_string_literal: true

require 'dry-container'

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_client, -> { GithubClientStub }
    register :open3, -> { Open3Stub }
    register :payload, ->(params = {}) { PayloadStub.new(params) }
    register :rubocop, ->(repository_full_name) { RubocopReportStub.new(repository_full_name) }
  else
    register :github_client, -> { Octokit::Client }
    register :open3, -> { Open3 }
    register :payload, ->(params = {}) { RealPayload.new(params) }
    register :rubocop, ->(repository_full_name) { RubocopReport.new(repository_full_name) }
  end
end
