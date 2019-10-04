class CreateWkGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_groups do |t|
      t.string   :category, limit: Wk::Group::MAX_CATEGORY
      t.string   :vocab_list, limit: Wk::Group::MAX_VOCAB_LIST

      t.timestamps
    end

    create_table :wk_groups_vocabs do |t|
      t.references :group, null: false
      t.references :vocab, null: false
    end
  end
end
