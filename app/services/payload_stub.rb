# frozen_string_literal: true

class PayloadStub
  def payload
    repository = Repository.last
    {
      'repository' => { 'id' => repository.id, 'full_name' => repository.full_name },
      'pusher' => { 'email' => 'test@example.com' },
      'commits' => [{ 'sha' => 'fake_commit_sha' }]
    }.to_json
  end
end
