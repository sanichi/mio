class AddStarsCountToConstellations < ActiveRecord::Migration[7.1]
  def change
    add_column :constellations, :stars_count, :integer
  end
end
