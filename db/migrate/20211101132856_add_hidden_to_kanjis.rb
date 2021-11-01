class AddHiddenToKanjis < ActiveRecord::Migration[6.1]
  def change
    add_column :wk_kanjis, :hidden, :boolean, default: false
  end
end
