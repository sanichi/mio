class AddKanjiToRadical < ActiveRecord::Migration[5.2]
  def change
    add_column :radicals, :kanji_id, :integer
  end
end
