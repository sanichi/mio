class DropVehicles < ActiveRecord::Migration[6.0]
  def up
    drop_table :parkings
    drop_table :residents
    drop_table :vehicles
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
