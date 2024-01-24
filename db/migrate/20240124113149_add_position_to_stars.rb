class AddPositionToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :alpha, :string, limit: 6
    add_column :stars, :delta, :string, limit: 7
  end
end
