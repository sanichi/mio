class CreateRadicals < ActiveRecord::Migration[5.2]
  def change
    create_table :radicals do |t|
      t.boolean  :burned, default: false
      t.integer  :level, limit: 1
      t.string   :meaning, limit: Radical::MAX_MEANING
      t.string   :symbol, limit: Radical::MAX_SYMBOL
    end
  end
end
