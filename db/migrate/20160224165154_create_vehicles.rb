class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.integer  :resident_id
      t.string   :registration, limit: Vehicle::MAX_REG

      t.timestamps null: false
    end
  end
end
