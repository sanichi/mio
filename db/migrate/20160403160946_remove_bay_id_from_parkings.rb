class RemoveBayIdFromParkings < ActiveRecord::Migration
  def up
    remove_column :parkings, :bay_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
