# frozen_string_literal: true

class PayloadStub
  def initialize(repository_id, repository_full_name)
    @repository_id = repository_id
    @repository_full_name = repository_full_name
  end

  def payload
    {
      'repository' => { 'id' => @repository_id, 'full_name' => @repository_full_name },
      'pusher' => { 'email' => 'test@example.com' },
      'commits' => [{ 'sha' => 'fake_commit_sha' }]
    }.to_json
  end
end
