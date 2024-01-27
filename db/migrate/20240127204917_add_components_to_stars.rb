class AddComponentsToStars < ActiveRecord::Migration[7.1]
  def change
    add_column :stars, :components, :integer, limit: 1, default: 1
  end
end
