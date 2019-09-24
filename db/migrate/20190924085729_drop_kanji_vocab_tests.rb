class DropKanjiVocabTests < ActiveRecord::Migration[6.0]
  def up
    drop_table :vocab_tests
    drop_table :vocab_questions
    drop_table :kanji_tests
    drop_table :kanji_questions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
