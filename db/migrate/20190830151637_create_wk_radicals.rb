class CreateWkRadicals < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_radicals do |t|
      t.integer  :wk_id
      t.integer  :level, limit: 1
      t.text     :mnemonic
      t.string   :name, limit: Wk::Radical::MAX_NAME
      t.string   :character, limit: 1
    end
  end
end
