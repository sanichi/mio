class AddFavouriteToWkKanjis < ActiveRecord::Migration[8.1]
  def change
    add_column :wk_kanjis, :favourite, :boolean, default: false, null: false
  end
end
