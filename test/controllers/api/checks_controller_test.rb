# frozen_string_literal: true

require 'test_helper'
class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @repository = repositories(:one)
  end

  test 'should create check' do
    post '/api/checks', params: {
      repository: { id: @repository.github_id, full_name: @repository.full_name }
    }
    assert_response :ok

    check = Repository::Check.last
    assert_equal @repository.id, check.repository_id
    assert_equal 'MyString/Mystring', check.repository.full_name
    assert_equal 'MyString', check.commit_id
  end
end
