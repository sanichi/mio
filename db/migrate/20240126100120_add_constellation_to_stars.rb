class AddConstellationToStars < ActiveRecord::Migration[7.1]
  def change
    add_reference :stars, :constellation, foreign_key: true
  end
end
