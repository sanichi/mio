class CreateVocabQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :vocab_questions do |t|
      t.integer  :vocab_id
      t.integer  :vocab_test_id
      t.string   :kanji, limit: Vocab::MAX_KANJI
      t.string   :meaning, limit: Vocab::MAX_MEANING
      t.string   :reading, limit: Vocab::MAX_READING
      t.boolean  :kanji_correct, default: false
      t.boolean  :meaning_correct, default: false
      t.boolean  :reading_correct, default: false
      t.datetime :created_at

      t.index :vocab_id
      t.index :vocab_test_id
    end
  end
end
