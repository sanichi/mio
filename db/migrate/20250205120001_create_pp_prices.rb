class CreatePpPrices < ActiveRecord::Migration[7.0]
  def change
    create_table :pp_prices do |t|
      t.references :station, null: false, foreign_key: { to_table: :pp_stations }
      t.decimal    :price_pence, precision: 5, scale: 1, null: false
      t.datetime   :price_last_updated, null: false

      t.timestamps
    end

    add_index :pp_prices, [:station_id, :price_last_updated]
  end
end
