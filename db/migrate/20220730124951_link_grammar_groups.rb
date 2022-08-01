class LinkGrammarGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :grammar_groups_grammars, id: false do |t|
      t.belongs_to :grammar
      t.belongs_to :grammar_group
    end
  end
end
