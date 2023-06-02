class CreateWkKanas < ActiveRecord::Migration[7.0]
  def change
    create_table :wk_kanas do |t|
      t.string   :characters, limit: Wk::Vocab::MAX_CHARACTERS
      t.boolean  :hidden, default: false
      t.date     :last_updated
      t.integer  :level, limit: 2
      t.string   :meaning, limit: Wk::Vocab::MAX_MEANING
      t.text     :meaning_mnemonic
      t.text     :notes
      t.integer  :wk_id, default: 0
      t.string   :parts, limit: Wk::Vocab::MAX_PARTS

      t.timestamps
    end
  end
end
