class DropSimilarWordsKanjisProperly < ActiveRecord::Migration[6.0]
  def up
    drop_table :similar_kanjis
    drop_table :similar_words
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
