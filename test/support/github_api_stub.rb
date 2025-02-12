# frozen_string_literal: true

class GithubApiStub
  def fetch_repo_data(repo_name)
    { name: repo_name, owner: 'test_user' }
  end
end
