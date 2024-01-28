class AddRadiusToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :radius, :decimal, precision: 6, scale: 2
  end
end
