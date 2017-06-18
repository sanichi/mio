class CreateKanjiAndReadings < ActiveRecord::Migration[5.1]
  def change
    create_table :kanjis do |t|
      t.string   :symbol, limit: Kanji::MAX_SYMBOL
      t.integer  :onyomi, default: 0
      t.integer  :kunyomi, default: 0
    end

    create_table :yomis do |t|
      t.belongs_to :kanji, index: true
      t.belongs_to :reading, index: true
      t.boolean  :on, default: true
    end

    create_table :readings do |t|
      t.string   :kana, limit: Reading::MAX_KANA
      t.integer  :onyomi, default: 0
      t.integer  :kunyomi, default: 0
    end
  end
end
