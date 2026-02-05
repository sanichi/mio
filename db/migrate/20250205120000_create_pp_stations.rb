class CreatePpStations < ActiveRecord::Migration[7.0]
  def change
    create_table :pp_stations do |t|
      t.string   :node_id,        limit: 64, null: false
      t.string   :name,           limit: 75, null: false
      t.string   :brand,          limit: 30
      t.string   :address,        limit: 50
      t.string   :postcode,       limit: 10
      t.decimal  :latitude,       precision: 10, scale: 7, null: false
      t.decimal  :longitude,      precision: 10, scale: 7, null: false
      t.string   :preferred_name, limit: 75

      t.timestamps
    end

    add_index :pp_stations, :node_id, unique: true
  end
end
