class DropConversations < ActiveRecord::Migration[6.0]
  def up
    drop_table :conversations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
