class AddLuminosityToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :luminosity, :decimal, precision: 10, scale: 2
  end
end
