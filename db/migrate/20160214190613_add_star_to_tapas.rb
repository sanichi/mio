class AddStarToTapas < ActiveRecord::Migration
  def change
    add_column :tapas, :star, :boolean, default: false
  end
end
