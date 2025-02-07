class DropTestsAndBorders < ActiveRecord::Migration[8.0]
  def up
    drop_table :tests
    drop_table :borders
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
