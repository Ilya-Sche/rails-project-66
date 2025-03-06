# frozen_string_literal: true

require 'test_helper'
class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  test 'should process push event and create webhook' do
    post '/api/checks', params: {}, headers: { 'X-GitHub-Event' => 'push' }

    assert_response :ok
    json_response = response.parsed_body

    assert_equal 'Webhook processed successfully', json_response['message']
  end
end
