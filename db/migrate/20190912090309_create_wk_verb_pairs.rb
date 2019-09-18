class CreateWkVerbPairs < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_verb_pairs do |t|
      t.string   :category, limit: Wk::VerbPair::MAX_CATEGORY
      t.string   :tag, limit: Wk::VerbPair::MAX_TAG
      t.integer  :transitive_id, :intransitive_id

      t.index    :tag
      t.index    :intransitive_id
      t.index    :transitive_id
      t.index    [:transitive_id, :intransitive_id]
    end
  end
end
