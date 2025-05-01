class CreateKsJournals < ActiveRecord::Migration[8.0]
  def change
    create_table :ks_journals do |t|
      t.integer  :boot, :mem, :top, :proc, :warnings, default: 0
      t.boolean  :okay, default: true
      t.text     :note, default: ""
      t.datetime :created_at
    end

    add_index :ks_journals, :created_at, unique: true
  end
end
