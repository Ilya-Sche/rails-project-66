# frozen_string_literal: true

class PayloadStub
  def initialize(params = {})
    @params = params
  end

  def payload
    repository = Repository.find_by(github_id: @params['repository']['id'])

    {
      'repository' => { 'id' => repository.github_id, 'full_name' => repository.full_name },
      'pusher' => { 'email' => 'test@example.com' },
      'commits' => [{ 'sha' => 'fake_commit_sha' }]
    }.to_json
  end
end
