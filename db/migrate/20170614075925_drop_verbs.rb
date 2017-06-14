class DropVerbs < ActiveRecord::Migration[5.1]
  def up
    drop_table :verbs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
