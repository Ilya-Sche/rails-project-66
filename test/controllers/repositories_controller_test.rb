# frozen_string_literal: true

require 'webmock/minitest'
require 'test_helper'
require 'ostruct'
class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    stub_request(:post, 'https://api.github.com/repos/octocat/Hello-World/hooks')
      .with(
        body: '{"name":"web","config":{"url":"https://ec5e-195-54-33-188.ngrok-free.app/api/checks","content_type":"json"},"events":["push"],"active":true}',
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'token token_1',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Octokit Ruby Gem 9.2.0'
        }
      )
      .to_return(status: 200, body: '[{"id": 1, "name": "web", "config": {"url": "http://example.com"}}]', headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, 'https://api.github.com/repos/octocat/Hello-World/hooks')
      .with(
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Authorization' => 'token token_1',
          'User-Agent' => 'Octokit Ruby Gem 9.2.0',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: '[{"id": 1, "name": "web", "config": {"url": "http://example.com"}}]', headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, 'https://api.github.com/repos/octocat/Hello-World')
      .with(
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'Authorization' => 'token token_1',
          'User-Agent' => 'Octokit Ruby Gem 9.2.0'
        }
      )
      .to_return(status: 200, body: {
        'name' => 'Hello-World',
        'id' => 12_345,
        'full_name' => 'octocat/Hello-World',
        'language' => 'Ruby',
        'clone_url' => 'https://github.com/octocat/Hello-World.git',
        'ssh_url' => 'git@github.com:octocat/Hello-World.git'
      }.to_json, headers: { 'Content-Type' => 'application/json' })

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

    stub_request(:get, 'https://api.github.com/user/repos?per_page=100')
      .to_return(
        status: 200,
        body: [
          { 'id' => 1, 'name' => 'repo1', 'owner' => { 'login' => 'user1' } },
          { 'id' => 2, 'name' => 'repo2', 'owner' => { 'login' => 'user2' } }
        ].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

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
    repo_id = 'octocat/Hello-World'

    post repositories_path, params: { repo_id: }
    assert_redirected_to repositories_path
    repository = @user.repositories.last
    assert_equal 'Hello-World', repository.name
    assert_equal 'octocat/Hello-World', repository.full_name
    assert_equal 'Ruby', repository.language
  end
end
