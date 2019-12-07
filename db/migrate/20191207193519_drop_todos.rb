class DropTodos < ActiveRecord::Migration[6.0]
  def up
    drop_table :todos
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
