class CreateVerbs < ActiveRecord::Migration[5.1]
  def change
    create_table :verbs do |t|
      t.string   :category, limit: Verb::MAX_CATEGORY
      t.string   :kanji, limit: Verb::MAX_KANJI
      t.string   :meaning, limit: Verb::MAX_MEANING
      t.string   :reading, limit: Verb::MAX_READING
      t.boolean  :transitive

      t.timestamps null: false
    end
  end
end
