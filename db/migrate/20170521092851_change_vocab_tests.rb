class ChangeVocabTests < ActiveRecord::Migration[5.1]
  def change
    change_table :vocab_tests do |t|
      t.rename :complete, :total
      t.integer :attempts, limit: 2, default: 0
      t.integer :correct, limit: 2, default: 0
      t.integer :hit_rate, limit: 1, default: 0
      t.integer :progress_rate, limit: 1, default: 0
    end
  end
end
