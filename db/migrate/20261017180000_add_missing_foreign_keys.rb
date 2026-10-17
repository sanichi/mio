class AddMissingForeignKeys < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :partnerships, :people, column: :husband_id
    add_foreign_key :partnerships, :people, column: :wife_id
    add_foreign_key :people, :people, column: :father_id
    add_foreign_key :people, :people, column: :mother_id
    add_foreign_key :transactions, :classifiers
    add_foreign_key :wk_combos, :wk_vocabs, column: :vocab_id
    add_foreign_key :wk_readings, :wk_vocabs, column: :vocab_id
    add_foreign_key :wk_verb_pairs, :wk_vocabs, column: :transitive_id
    add_foreign_key :wk_verb_pairs, :wk_vocabs, column: :intransitive_id
  end
end
