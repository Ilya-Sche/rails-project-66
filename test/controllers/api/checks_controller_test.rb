# frozen_string_literal: true

require 'test_helper'
class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @repository = repositories(:one)
    @payload_stub = PayloadStub.new
  end

  test 'should create check' do
    payload = JSON.parse(@payload_stub.payload)

    post '/api/checks', params: {
      repository: { id: @repository.id, full_name: @repository.full_name },
      payload: payload
    }

    assert_response :ok

    check = Repository::Check.last
    assert_not_nil check
    assert_equal 'MyString/Mystring', check.repository.full_name
    assert_equal 'MyString', check.commit_id
  end

  test 'should process push event and create webhook' do
    post '/api/checks', params: {}, headers: { 'X-GitHub-Event' => 'push' }

    assert_response :ok
    json_response = response.parsed_body

    assert_equal 'Webhook processed successfully', json_response['message']
  end
end
