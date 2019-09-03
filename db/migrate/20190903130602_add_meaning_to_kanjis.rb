class AddMeaningToKanjis < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_kanjis, :meaning, :string, limit: Wk::Kanji::MAX_MEANING
    add_column :wk_kanjis, :meaning_mnemonic, :text
    add_column :wk_kanjis, :reading_mnemonic, :text
  end
end
