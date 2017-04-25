class CreateVocab < ActiveRecord::Migration[5.0]
  def change
    create_table :vocabs do |t|
      t.string   :audio, limit: Vocab::MAX_AUDIO
      t.string   :kana, limit: Vocab::MAX_KANA
      t.string   :kanji, limit: Vocab::MAX_KANJI
      t.string   :meaning, limit: Vocab::MAX_MEANING
      t.integer  :kanji_correct, :kanji_incorrect, :meaning_correct, :meaning_incorrect, limit: 2, default: 0

      t.timestamps null: false
    end
  end
end
