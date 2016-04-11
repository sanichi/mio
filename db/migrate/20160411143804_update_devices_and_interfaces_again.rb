class UpdateDevicesAndInterfacesAgain < ActiveRecord::Migration
  def up
    remove_column :devices, :manufacturer
    add_column :interfaces, :manufacturer, :string, limit: Interface::MAX_MANU
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
