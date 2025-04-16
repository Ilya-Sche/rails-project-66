class AddUniquenessToRepositoryGithubId < ActiveRecord::Migration[7.2]
  def change
    add_index :repositories, :github_id, unique: true
  end
end
