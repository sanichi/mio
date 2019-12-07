class DropVehicles < ActiveRecord::Migration[6.0]
  drop_table :parkings
  drop_table :residents
  drop_table :vehicles
end
