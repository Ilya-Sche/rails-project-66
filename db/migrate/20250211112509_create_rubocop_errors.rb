class CreateRubocopErrors < ActiveRecord::Migration[7.2]
  def change
    create_table :rubocop_errors do |t|
      t.string :offense_code
      t.text :message
      t.integer :line
      t.string :file
      t.references :check, null: false, foreign_key: { to_table: :repository_checks }

      t.timestamps
    end
  end
end
