class AddIndexesToKanjis < ActiveRecord::Migration[5.1]
  def change
    add_index :kanjis, :symbol
    add_index :kanjis, :meaning
  end
end
