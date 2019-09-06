class AddReadingsToV2Kanjis < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_kanjis, :reading, :string, limit: Wk::Kanji::MAX_READING
  end
end
