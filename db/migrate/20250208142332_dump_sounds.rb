class DumpSounds < ActiveRecord::Migration[8.0]
  def up
    drop_table :sounds
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
