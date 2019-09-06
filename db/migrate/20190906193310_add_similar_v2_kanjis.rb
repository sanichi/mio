class AddSimilarV2Kanjis < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_kanjis_kanjis, :id => false do |t|
      t.integer :kanji_id
      t.integer :similar_id
    end

    add_index :wk_kanjis_kanjis, :kanji_id
    add_index :wk_kanjis_kanjis, :similar_id
  end
end
