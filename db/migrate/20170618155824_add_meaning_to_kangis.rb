class AddMeaningToKangis < ActiveRecord::Migration[5.1]
  def change
    add_column :kanjis, :meaning, :string, limit: Kanji::MAX_MEANING
  end
end
