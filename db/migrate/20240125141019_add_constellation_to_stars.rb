class AddConstellationToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :constellation, :string, limit: Star::MAX_NAME
  end
end
