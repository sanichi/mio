class CreateInterfaces < ActiveRecord::Migration
  def change
    create_table :interfaces do |t|
      t.string   :address, limit: Interface::MAX_ADDR
      t.integer  :device_id
      t.string   :name, limit: Interface::MAX_NAME

      t.timestamps null: false
    end
  end
end
