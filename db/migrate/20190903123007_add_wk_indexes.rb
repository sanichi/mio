class AddWkIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index("wk_radicals", "wk_id", unique: true)
    add_index("wk_kanjis", "wk_id", unique: true)
  end
end
