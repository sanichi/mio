class CreateGrammarGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :grammar_groups do |t|
      t.string   :title, limit: 256

      t.timestamps
    end
  end
end
