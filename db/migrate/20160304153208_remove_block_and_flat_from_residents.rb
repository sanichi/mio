class RemoveBlockAndFlatFromResidents < ActiveRecord::Migration
  def up
    remove_column :residents, :block
    remove_column :residents, :flat
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
