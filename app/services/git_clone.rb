# frozen_string_literal: true

class GitClone
  def clone_repo(command)
    system(command)
  end
end
