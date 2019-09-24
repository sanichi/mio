class DropOccupationsVerbPairs < ActiveRecord::Migration[6.0]
  def up
    drop_table :occupations
    drop_table :verb_pairs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
