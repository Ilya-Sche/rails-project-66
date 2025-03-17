# frozen_string_literal: true

require 'test_helper'
require 'ostruct'
class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @repo = repositories(:one)
  end

  test 'should get index' do
    get repositories_path
    assert_response :success
    assert_select 'td', @repo.name
    assert_select 'td', @repo.language
  end

  test 'should show repository' do
    get repository_path(@repo)
    assert_response :success
  end

  test 'should get new' do
    get new_repository_path
    assert_response :success
  end

  test 'should create repository' do
    github_id = 123

    post repositories_path, params: { github_id: }

    assert_redirected_to repositories_path
    repository = @user.repositories.last
    assert_equal 'Hello-World', repository.name
    assert_equal 123, repository.github_id
    assert_equal 'octocat/Hello-World', repository.full_name
    assert_equal 'Ruby', repository.language
    assert_equal 'https://github.com/octocat/Hello-World.git', repository.clone_url
    assert_equal 'git@github.com:octocat/Hello-World.git', repository.ssh_url
  end
end
