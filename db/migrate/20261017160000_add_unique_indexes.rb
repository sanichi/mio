class AddUniqueIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :classifiers, "lower(name)", unique: true, name: "index_classifiers_on_lower_name"
    add_index :constellations, "lower(name)", unique: true, name: "index_constellations_on_lower_name"
    add_index :constellations, "lower(iau)", unique: true, name: "index_constellations_on_lower_iau"
    add_index :constellations, "lower(wikipedia)", unique: true, name: "index_constellations_on_lower_wikipedia"
    add_index :favourites, [:category, :name], unique: true
    add_index :flats, :bay, unique: true
    add_index :flats, [:building, :number], unique: true
    add_index :grammars, :title, unique: true
    add_index :grammars, :ref, unique: true
    add_index :grammar_groups, :title, unique: true
    add_index :masses, :date, unique: true
    add_index :mass_events, :start, unique: true
    add_index :mass_events, :finish, unique: true
    add_index :matches, [:season, :away_team_id, :home_team_id], unique: true
    add_index :matches, [:home_team_id, :date], unique: true
    add_index :misas, :url, unique: true
    add_index :misas, :alt, unique: true
    add_index :misas, [:series, :number], unique: true
    add_index :notes, [:series, :number], unique: true
    add_index :partnerships, [:wife_id, :husband_id], unique: true
    add_index :pictures, :image, unique: true
    add_index :places, :ename, unique: true
    add_index :places, :jname, unique: true
    add_index :places, :vbox, unique: true
    add_index :places, :wiki, unique: true
    add_index :pp_stations, :preferred_name, unique: true
    add_index :stars, [:constellation_id, :bayer], unique: true
    add_index :stars, "lower(name)", unique: true, name: "index_stars_on_lower_name"
    add_index :stars, "lower(wikipedia)", unique: true, name: "index_stars_on_lower_wikipedia"
    add_index :stars, :rank, unique: true
    add_index :subscriptions, :payee, unique: true
    add_index :teams, :name, unique: true
    add_index :teams, :short, unique: true
    add_index :tutorials, :date, unique: true
    add_index :users, :email, unique: true
    add_index :wk_audios, :file, unique: true
    add_index :wk_kanas, :characters, unique: true
    add_index :wk_kanas, :wk_id, unique: true
    add_index :wk_kanjis, :character, unique: true
    add_index :wk_radicals, :character, unique: true
    add_index :wk_radicals, :name, unique: true
    remove_index :wk_verb_pairs, column: [:transitive_id, :intransitive_id]
    add_index :wk_verb_pairs, [:transitive_id, :intransitive_id], unique: true
    add_index :wk_vocabs, :characters, unique: true
    add_index :grammar_groups_grammars, [:grammar_id, :grammar_group_id], unique: true
    add_index :people_pictures, [:person_id, :picture_id], unique: true
    add_index :wk_examples_vocabs, [:example_id, :vocab_id], unique: true
    add_index :wk_groups_vocabs, [:group_id, :vocab_id], unique: true
    add_index :wk_kanjis_radicals, [:kanji_id, :radical_id], unique: true
    add_index :wk_kanjis_kanjis, [:kanji_id, :similar_id], unique: true
  end
end
