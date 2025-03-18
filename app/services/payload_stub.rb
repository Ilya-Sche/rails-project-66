# frozen_string_literal: true

class PayloadStub
  def payload
    {
      'repository' => { 'id' => 980_190_962, 'full_name' => 'MyString/Mystring' },
      'pusher' => { 'email' => 'test@example.com' },
      'commits' => [{ 'sha' => 'fake_commit_sha' }]
    }.to_json
  end
end
