class IncreaseVerbPairTagSize < ActiveRecord::Migration[6.0]
  def up
    change_column :wk_verb_pairs, :tag, :string, limit: 5000
  end

  def down
    change_column :wk_verb_pairs, :tag, :string, limit: 20
  end
end
