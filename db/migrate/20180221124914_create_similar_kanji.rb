class CreateSimilarKanji < ActiveRecord::Migration[5.1]
  def change
    create_table :similar_kanjis do |t|
      t.string :kanjis, limit: SimilarKanji::MAX_KANJIS
      t.timestamps null: false
    end
  end
end
