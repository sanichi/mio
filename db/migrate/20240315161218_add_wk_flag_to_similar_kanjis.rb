class AddWkFlagToSimilarKanjis < ActiveRecord::Migration[7.1]
  def change
    add_column :wk_kanjis_kanjis, :wk, :boolean, default: true
  end
end
