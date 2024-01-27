class AddBayerToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :bayer, :string, limit: 3
  end
end
