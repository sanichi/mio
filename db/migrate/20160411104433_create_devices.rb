class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string   :manufacturer, limit: Device::MAX_MFTR
      t.string   :network_name, limit: Device::MAX_NNAM
      t.string   :real_name, limit: Device::MAX_RNAM
      t.text     :notes

      t.timestamps null: false
    end
  end
end
