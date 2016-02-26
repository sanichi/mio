class CreateParkings < ActiveRecord::Migration
  def change
    create_table :parkings do |t|
      t.integer  :bay_id
      t.integer  :vehicle_id

      t.timestamps null: false
    end

    add_index :parkings, :bay_id
    add_index :parkings, :vehicle_id
  end
end
