# frozen_string_literal: true

class GithubClientStub
  def initialize(access_token: nil, auto_paginate: nil)
    @access_token = access_token
    @auto_paginate = auto_paginate
  end

  def commits(_repo_full_name)
    [Struct.new(:sha).new('fake_commit_sha')]
  end

  def repo(github_id)
    Struct.new(:name, :id, :full_name, :language, :clone_url, :ssh_url).new(
      'Hello-World',
      github_id,
      'octocat/Hello-World',
      'Ruby',
      'https://github.com/octocat/Hello-World.git',
      'git@github.com:octocat/Hello-World.git'
    )
  end

  def repos
    [
      Struct.new(:name, :id, :full_name, :language, :clone_url, :ssh_url).new(
        'Hello-World',
        123,
        'octocat/Hello-World',
        'Ruby',
        'https://github.com/octocat/Hello-World.git',
        'git@github.com:octocat/Hello-World.git'
      ),
      Struct.new(:name, :id, :full_name, :language, :clone_url, :ssh_url).new(
        'Another-Repo',
        123,
        'octocat/Another-Repo',
        'JavaScript',
        'https://github.com/octocat/Another-Repo.git',
        'git@github.com:octocat/Another-Repo.git'
      )
    ]
  end

  def hooks(_repo_full_name)
    [
      {
        'config' => {
          'url' => 'https://rails-65-3afi.onrender.com/api/checks'
        }
      }
    ]
  end
end
