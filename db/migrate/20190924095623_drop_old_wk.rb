class DropOldWk < ActiveRecord::Migration[6.0]
  def up
    drop_table :kanjis
    drop_table :radicals
    drop_table :readings
    drop_table :vocabs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
