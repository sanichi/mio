class CreateOccupations < ActiveRecord::Migration[5.1]
  def change
    create_table :occupations do |t|
      t.string   :kanji, limit: Vocab::MAX_KANJI
      t.string   :meaning, limit: Vocab::MAX_MEANING
      t.string   :reading, limit: Vocab::MAX_READING
      t.integer  :vocab_id
    end
  end
end
