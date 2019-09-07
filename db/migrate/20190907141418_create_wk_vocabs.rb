class CreateWkVocabs < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_vocabs do |t|
      t.date     :last_updated
      t.integer  :level, limit: 1
      t.integer  :wk_id
    end

    add_index :wk_vocabs, :wk_id, unique: true
  end
end
