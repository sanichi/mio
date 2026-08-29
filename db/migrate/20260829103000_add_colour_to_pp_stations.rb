class AddColourToPpStations < ActiveRecord::Migration[8.0]
  # A categorical palette chosen so that thin lines stay tellable apart.
  PALETTE = %w[
    e6194b 3cb44b 4363d8 f58231 911eb4 008080 9a6324
    f032e6 808000 000075 800000 00b8d4 4a4a4a
  ]

  def up
    add_column :pp_stations, :colour, :string, limit: 6, null: false, default: Pp::Station::DEFAULT_COLOUR

    Pp::Station.reset_column_information
    Pp::Station.order(:id).each_with_index do |station, index|
      station.update_column(:colour, PALETTE[index % PALETTE.size])
    end
  end

  def down
    remove_column :pp_stations, :colour
  end
end
