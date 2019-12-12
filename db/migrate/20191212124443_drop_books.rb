class DropBooks < ActiveRecord::Migration[6.0]
  def up
    drop_table :books
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
