# frozen_string_literal: true

class PayloadStub
  def payload
    {
      'repository' => { 'full_name' => 'test_user/test_repo', 'id' => '123' },
      'pusher' => { 'email' => 'test@example.com' },
      'commits' => [{ 'sha' => 'fake_commit_sha' }]
    }.to_json
  end
end
