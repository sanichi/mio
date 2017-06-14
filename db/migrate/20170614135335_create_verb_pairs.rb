class CreateVerbPairs < ActiveRecord::Migration[5.1]
  def change
    create_table :verb_pairs do |t|
      t.string   :category, limit: VerbPair::MAX_CATEGORY
      t.string   :tag, limit: VerbPair::MAX_TAG
      t.integer  :transitive_id, :intransitive_id
      t.index    :transitive_id
      t.index    :intransitive_id
      t.index    :tag
      t.index    [:transitive_id, :intransitive_id]

      t.timestamps null: false
    end
  end
end
