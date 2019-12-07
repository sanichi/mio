class DropInterfaces < ActiveRecord::Migration[6.0]
  def up
    drop_table :interfaces
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
