class CreateWkCombos < ActiveRecord::Migration[8.0]
  def change
    create_table :wk_combos do |t|
      t.belongs_to :vocab, index: true

      t.string   :ja, limit: Wk::Combo::MAX_COMBO
      t.string   :en, limit: Wk::Combo::MAX_COMBO

      t.timestamps
    end

    add_column :wk_vocabs, :combos_count, :integer, default: 0, null: false
  end
end
