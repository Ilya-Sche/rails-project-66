# frozen_string_literal: true

require "test_helper"
require 'ostruct'
class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @repo = repositories(:one)
  end

  test "should get index" do
    get repositories_path
    assert_response :success
    assert_select 'td', @repo.name
    assert_select 'td', @repo.language
  end

  test "should create repository" do

    Octokit::Client.class_eval do
      def repo(repo_id)
        OpenStruct.new(
          name: 'Hello-World',
          id: 12345,
          full_name: 'octocat/Hello-World',
          language: 'Ruby',
          clone_url: 'https://github.com/octocat/Hello-World.git',
          ssh_url: 'git@github.com:octocat/Hello-World.git'
        )
      end
    end

    repo_id = 'octocat/Hello-World'

    post repositories_path, params: { repo_id: }

    assert_redirected_to repositories_path
    
    repository = @user.repositories.last
    assert_equal 'Hello-World', repository.name
    assert_equal 'octocat/Hello-World', repository.full_name
    assert_equal 'Ruby', repository.language
  end
end
