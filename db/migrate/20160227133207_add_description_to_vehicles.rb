class AddDescriptionToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :description, :string, limit: Vehicle::MAX_DESC
  end
end
