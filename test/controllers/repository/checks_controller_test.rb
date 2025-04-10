# frozen_string_literal: true

require 'test_helper'
class Repository::ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repo = repositories(:one)
    @check = repository_checks(:one)
    sign_in @user
  end

  test 'should show check' do
    get repository_check_path(@repo, @check)
    assert_response :success
  end

  test 'should create check' do
    assert_difference('Repository::Check.count', 1) do
      post repository_checks_path(@repo), params: { repository_check: { repository_id: @repo.id } }
    end

    assert_performed_jobs 1, only: Repository::CheckJob do
      post repository_checks_path(@repo), params: { repository_check: { repository_id: @repo.id } }
    end

    check = Repository::Check.last
    check.reload

    assert_redirected_to repository_path(@repo)

    assert_equal 'fake_commit_sha', check.commit_id
    assert_equal @repo.id, check.repository_id
  end
end
