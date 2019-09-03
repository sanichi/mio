class CreateWkKanjis < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_kanjis do |t|
      t.string   :character, limit: 1
      t.integer  :level, limit: 1
      t.text     :meaning_mnemonic
      t.text     :reading_mnemonic
      t.integer  :wk_id
    end
  end
end
