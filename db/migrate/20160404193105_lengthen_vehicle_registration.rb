class LengthenVehicleRegistration < ActiveRecord::Migration
  def up
    change_column :vehicles, :registration, :string, limit: Vehicle::MAX_REG
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
