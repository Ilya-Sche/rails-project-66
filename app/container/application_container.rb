# frozen_string_literal: true

require 'dry/container'

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :docker_exercise_api, -> { DockerExerciseApiStub }
    register :github_api, -> { GithubApiStub }
    register :linter, -> { LinterStub }
  else
    register :docker_exercise_api, -> { DockerExerciseApi }
    register :github_api, -> { GithubApi }
    register :linter, -> { Linter }
  end
end
