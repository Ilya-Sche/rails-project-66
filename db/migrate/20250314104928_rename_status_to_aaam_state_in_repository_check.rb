class RenameStatusToAaamStateInRepositoryCheck < ActiveRecord::Migration[7.2]
  def change
    rename_column :repository_checks, :status, :aasm_state
  end
end
