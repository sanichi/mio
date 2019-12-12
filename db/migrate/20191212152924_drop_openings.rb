class DropOpenings < ActiveRecord::Migration[6.0]
  def up
    drop_table :openings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
