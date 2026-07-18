class AddFormerFavouriteToWkKanjis < ActiveRecord::Migration[8.1]
  def change
    add_column :wk_kanjis, :former_favourite, :datetime
  end
end
