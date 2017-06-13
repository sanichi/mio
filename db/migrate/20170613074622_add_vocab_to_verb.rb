class AddVocabToVerb < ActiveRecord::Migration[5.1]
  def change
    change_table :verbs do |t|
      t.integer  :vocab_id
      t.index    :vocab_id
    end
  end
end
