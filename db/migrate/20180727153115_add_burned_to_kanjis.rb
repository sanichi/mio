class AddBurnedToKanjis < ActiveRecord::Migration[5.2]
  def change
    add_column :kanjis, :burned, :boolean, default: false
  end
end
