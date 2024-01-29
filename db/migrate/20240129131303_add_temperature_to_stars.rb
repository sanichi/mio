class AddTemperatureToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :temperature, :integer, limit: 3
  end
end
