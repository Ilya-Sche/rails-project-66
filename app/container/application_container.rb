# frozen_string_literal: true

require 'dry-container'

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_client, -> { GithubClientStub }
    register :open3, -> { Open3Stub }
    register :git_clone, -> { GitCloneStub }
    register :payload, -> { PayloadStub.new }
    register :rubocop, ->(repository_full_name) { RubocopReportStub.new(repository_full_name) }
    register :send_report, ->(repository_full_name) { SendReportStub.new(repository_full_name) }

  else
    register :github_client, -> { Octokit::Client }
    register :open3, -> { Open3 }
    register :git_clone, -> { GitClone.new }
    register :payload, -> { RealPayload }
    register :rubocop, -> { RubocopReport }
    register :send_report, -> { SendReport }

  end
end
