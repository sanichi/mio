class DropBays < ActiveRecord::Migration
  def up
    drop_table :bays
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
