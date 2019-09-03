class CreateWkRadicals < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_radicals do |t|
      t.string   :character, limit: 1
      t.integer  :level, limit: 1
      t.text     :mnemonic
      t.string   :name, limit: Wk::Radical::MAX_NAME
      t.integer  :wk_id
    end
  end
end
