class CreateKanjiTestAndQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :kanji_tests do |t|
      t.integer  :attempts, limit: 2, default: 0
      t.integer  :correct, limit: 2, default: 0
      t.integer  :hit_rate, limit: 1, default: 0
      t.integer  :level, limit: 2
      t.integer  :progress_rate, limit: 1, default: 0
      t.integer  :total, limit: 2, default: 0

      t.timestamps null: false
    end

    create_table :kanji_questions do |t|
      t.integer  :kanji_id
      t.integer  :kanji_test_id
      t.boolean  :answer, default: false
      t.datetime :created_at

      t.index :kanji_id
      t.index :kanji_test_id
    end
  end
end
