class AddMagnitudeToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :magnitude, :decimal, precision: 4, scale: 2
  end
end
