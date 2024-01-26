class AddMassToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :mass, :decimal, precision: 6, scale: 2
  end
end
