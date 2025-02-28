# frozen_string_literal: true

require 'mocha/minitest'
require 'test_helper'
class Repository::ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repo = repositories(:one)
    @check = repository_checks(:one)
    sign_in @user

    stub_request(:get, 'https://api.github.com/repos/MyString/Mystring')
      .with(
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'token token_1',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Octokit Ruby Gem 9.2.0'
        }
      )
      .to_return(status: 200, body: @repo.to_json, headers: {})

    stub_request(:get, 'https://api.github.com/repos/MyString/Mystring/commits')
      .with(
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Authorization' => 'token token_1',
          'User-Agent' => 'Octokit Ruby Gem 9.2.0'
        }
      )
      .to_return(status: 200, body: '[{"sha": "abc123", "commit": {"message": "Test commit"}}]', headers: {})

    stub_request(:get, 'https://api.github.com/user/repos?per_page=100')
      .with(
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Authorization' => 'token token_1',
          'User-Agent' => 'Octokit Ruby Gem 9.2.0'
        }
      )
      .to_return(status: 200, body: '[{"id": 1, "name": "MyString", "full_name": "MyString/Mystring"}]', headers: {})
  end

  test 'should show check' do
    get repository_check_path(@repo, @check)
    assert_response :success
  end

  test 'should create check' do
    commit_sha = 'abc123'

    Repository::ChecksController.any_instance.stubs(commit_sha: commit_sha)
    assert_difference('Repository::Check.count', 1) do
      post repository_checks_path(@repo), params: { repository_check: { commit_id: commit_sha, status: 'In progress', repository_id: @repo.id } }
    end
    assert_redirected_to repository_path(@repo)
    check = Repository::Check.last

    assert_equal 1, check.commit_id
    assert_equal 'In progress', check.status
    assert_equal @repo.id, check.repository_id
  end
end
