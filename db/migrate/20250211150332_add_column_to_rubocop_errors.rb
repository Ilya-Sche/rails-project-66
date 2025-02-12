class AddColumnToRubocopErrors < ActiveRecord::Migration[7.2]
  def change
    add_column :rubocop_errors, :column, :integer
  end
end
