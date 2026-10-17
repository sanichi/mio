class RemoveIndexesCoveredByUniqueIndexes < ActiveRecord::Migration[8.1]
  def change
    remove_index :grammar_groups_grammars, :grammar_id
    remove_index :matches, :home_team_id
    remove_index :people_pictures, :person_id
    remove_index :stars, :constellation_id
    remove_index :wk_examples_vocabs, :example_id
    remove_index :wk_groups_vocabs, :group_id
    remove_index :wk_kanjis_kanjis, :kanji_id
    remove_index :wk_kanjis_radicals, :kanji_id
  end
end
