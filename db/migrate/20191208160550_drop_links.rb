class DropLinks < ActiveRecord::Migration[6.0]
  def up
    drop_table :links
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
