class ReplaceCategoryByGroupPartTwo < ActiveRecord::Migration[5.1]
  def change
    remove_column :verb_pairs, :category
  end
end
