class AddRankToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :rank, :integer, limit: 1
  end
end
