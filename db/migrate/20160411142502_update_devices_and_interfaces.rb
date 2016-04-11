class UpdateDevicesAndInterfaces < ActiveRecord::Migration
  def up
    rename_column :devices, :real_name, :name
    remove_column :devices, :network_name
    rename_column :interfaces, :address, :mac_address
    add_column :interfaces, :ip_address, :string, limit: Interface::MAX_IPAD
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
