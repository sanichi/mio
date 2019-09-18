class AddSuffixesToVerbPairs < ActiveRecord::Migration[6.0]
  def change
    add_column :wk_verb_pairs, :transitive_suffix, :string, limit: Wk::VerbPair::MAX_SUFFIX
    add_column :wk_verb_pairs, :intransitive_suffix, :string, limit: Wk::VerbPair::MAX_SUFFIX
  end
end
