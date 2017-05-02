class AddIndexesToVocabs < ActiveRecord::Migration[5.0]
  def change
    add_column :vocabs, :level, :integer, limit: 1
    add_index :vocabs, :kana
    add_index :vocabs, :meaning
  end
end
