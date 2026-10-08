class DropYomis < ActiveRecord::Migration[8.1]
  def change
    drop_table :yomis do |t|
      t.boolean :important, default: true
      t.bigint :kanji_id
      t.boolean :on, default: true
      t.bigint :reading_id
      t.index :kanji_id
      t.index :reading_id
    end
  end
end
