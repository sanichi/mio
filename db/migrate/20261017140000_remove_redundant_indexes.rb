class RemoveRedundantIndexes < ActiveRecord::Migration[8.1]
  def change
    remove_index :wk_verb_pairs, :transitive_id
    remove_index :pp_prices, :station_id
  end
end
