class ReplaceCategoryByGroupPartOne < ActiveRecord::Migration[5.1]
  def up
    change_table :verb_pairs do |t|
      t.integer  :group, limit: 1
      t.index    :group
    end
    VerbPair.all.to_a.each do |p|
      p.update_column(:group, VerbPair::CATEGORIES.index(p.category))
    end
  end

  def down
    change_table :verb_pairs do |t|
      t.remove   :group
    end
  end
end
