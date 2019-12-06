class DropDragons < ActiveRecord::Migration[6.0]
  def up
    drop_table :dragons
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
