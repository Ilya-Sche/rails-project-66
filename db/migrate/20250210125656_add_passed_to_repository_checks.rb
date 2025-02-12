class AddPassedToRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :repository_checks, :passed, :boolean
  end
end
