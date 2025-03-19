# frozen_string_literal: true

class PayloadStub
  def initialize(params = {})
    @params = params
  end

  def payload
    repository = Repository.find_by(full_name: @params['repository']['full_name'])

    {
      'repository' => { 'id' => repository.id, 'full_name' => repository.full_name },
      'pusher' => { 'email' => 'test@example.com' },
      'commits' => [{ 'sha' => 'fake_commit_sha' }]
    }.to_json
  end
end
