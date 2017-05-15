class CreateVocabTests < ActiveRecord::Migration[5.1]
  def change
    create_table :vocab_tests do |t|
      t.integer  :complete, limit: 2, default: 0
      t.integer  :level, limit: 2
      t.string   :category, limit: VocabTest::MAX_CATEGORY

      t.timestamps null: false
    end
  end
end
