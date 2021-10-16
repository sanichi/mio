class CreateGrammars < ActiveRecord::Migration[6.1]
  def change
    create_table :grammars do |t|
      t.string   :title, limit: 128
      t.string   :regexp, limit: 64
      t.integer  :level, limit: 1, default: 5
      t.integer  :examples, array: true, default: []
      t.integer  :last_example_checked, default: 0
      t.text     :note

      t.timestamps
    end
  end
end
