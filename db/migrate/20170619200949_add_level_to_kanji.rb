class AddLevelToKanji < ActiveRecord::Migration[5.1]
  def change
    add_column :kanjis, :level, :integer, limit: 1
  end
end
