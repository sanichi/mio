class AddWikipediaToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :wikipedia, :string, limit: Star::MAX_NAME
    add_column :constellations, :wikipedia, :string, limit: Constellation::MAX_NAME
  end
end
