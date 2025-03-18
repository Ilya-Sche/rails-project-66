# frozen_string_literal: true

require 'test_helper'
class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  test 'should create check' do
    post '/api/checks', params: {
      repository: { id: 980_190_962, full_name: 'MyString/Mystring' }
    }

    assert_response :ok

    check = Repository::Check.last
    assert_equal 980_190_962, check.repository_id
    assert_equal 'MyString/Mystring', check.repository.full_name
    assert_equal 'MyString', check.commit_id
  end
end
