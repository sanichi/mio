class DropSimilarWordsKanji < ActiveRecord::Migration[6.0]
  def up
    drop_table :similar_kanji
    drop_table :similar_words
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
