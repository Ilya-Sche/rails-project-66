class RenameRubocopErrorsToLinterErrors < ActiveRecord::Migration[7.2]
  def change
    rename_table :rubocop_errors, :linter_errors
  end
end
