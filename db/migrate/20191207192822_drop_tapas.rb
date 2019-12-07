class DropTapas < ActiveRecord::Migration[6.0]
  def up
    drop_table :tapas
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
