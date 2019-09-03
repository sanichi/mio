class AddMeaningToKanjis < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_kanjis, :meaning, :string, limit: Wk::Kanji::MAX_MEANING
  end
end
