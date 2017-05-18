class ChangeVocabs < ActiveRecord::Migration[5.1]
  def change
    change_table :vocabs do |t|
      t.remove :kanji_correct, :kanji_incorrect, :meaning_correct, :meaning_incorrect
      t.rename :kana, :reading
    end
  end
end
