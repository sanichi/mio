class CreateWkVocabs < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_vocabs do |t|
      t.string   :characters, limit: Wk::Vocab::MAX_CHARACTERS
      t.date     :last_updated
      t.integer  :level, limit: 1
      t.string   :meaning, limit: Wk::Vocab::MAX_MEANING
      t.text     :meaning_mnemonic
      t.string   :parts, limit: Wk::Vocab::MAX_PARTS
      t.string   :reading, limit: Wk::Vocab::MAX_READING
      t.text     :reading_mnemonic
      t.integer  :wk_id
    end

    add_index :wk_vocabs, :wk_id, unique: true
  end
end
