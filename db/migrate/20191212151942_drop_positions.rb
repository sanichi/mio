class DropPositions < ActiveRecord::Migration[6.0]
  def up
    drop_table :positions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
