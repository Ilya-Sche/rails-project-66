# frozen_string_literal: true

class GitCloneStub
  def self.clone_repo(dir)
    FileUtils.mkdir_p(dir)
  end
end
