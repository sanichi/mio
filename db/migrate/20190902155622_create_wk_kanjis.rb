class CreateWkKanjis < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_kanjis do |t|
      t.integer  :wk_id
      t.integer  :level, limit: 1
      t.string   :character, limit: 1
    end
  end
end
