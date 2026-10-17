class AddNotNullConstraints < ActiveRecord::Migration[8.1]
  def change
    change_column_null :classifiers, :category, false
    change_column_null :classifiers, :color, false
    change_column_null :classifiers, :description, false
    change_column_null :classifiers, :name, false

    change_column_null :constellations, :name, false
    change_column_null :constellations, :iau, false

    change_column_null :favourites, :name, false
    change_column_null :favourites, :note, false

    change_column_null :grammars, :title, false

    change_column_null :grammar_groups, :title, false

    change_column_null :logins, :created_at, false

    change_column_null :masses, :date, false

    change_column_null :mass_events, :name, false
    change_column_null :mass_events, :start, false
    change_column_null :mass_events, :finish, false
    change_column_null :mass_events, :code, false

    change_column_null :matches, :date, false

    change_column_null :misas, :title, false

    change_column_null :notes, :stuff, false
    change_column_null :notes, :title, false

    change_column_null :partnerships, :husband_id, false
    change_column_null :partnerships, :wedding, false
    change_column_null :partnerships, :wife_id, false

    change_column_null :people, :first_names, false
    change_column_null :people, :last_name, false
    change_column_null :people, :known_as, false

    change_column_null :places, :ename, false
    change_column_null :places, :jname, false
    change_column_null :places, :reading, false
    change_column_null :places, :wiki, false

    change_column_null :stars, :name, false
    change_column_null :stars, :spectrum, false

    change_column_null :subscriptions, :payee, false
    change_column_null :subscriptions, :amount, false
    change_column_null :subscriptions, :source, false

    change_column_null :teams, :name, false
    change_column_null :teams, :short, false

    change_column_null :transactions, :date, false
    change_column_null :transactions, :description, false

    change_column_null :tutorials, :summary, false

    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false

    change_column_null :wk_audios, :file, false

    change_column_null :wk_combos, :ja, false
    change_column_null :wk_combos, :en, false

    change_column_null :wk_examples, :japanese, false
    change_column_null :wk_examples, :english, false

    change_column_null :wk_groups, :vocab_list, false

    change_column_null :wk_kanas, :characters, false
    change_column_null :wk_kanas, :meaning, false
    change_column_null :wk_kanas, :meaning_mnemonic, false
    change_column_null :wk_kanas, :parts, false

    change_column_null :wk_kanjis, :meaning, false
    change_column_null :wk_kanjis, :meaning_mnemonic, false
    change_column_null :wk_kanjis, :reading_mnemonic, false
    change_column_null :wk_kanjis, :last_updated, false
    change_column_null :wk_kanjis, :reading, false

    change_column_null :wk_radicals, :mnemonic, false
    change_column_null :wk_radicals, :name, false
    change_column_null :wk_radicals, :last_updated, false

    change_column_null :wk_readings, :characters, false

    change_column_null :wk_verb_pairs, :transitive_suffix, false
    change_column_null :wk_verb_pairs, :intransitive_suffix, false

    change_column_null :wk_vocabs, :characters, false
    change_column_null :wk_vocabs, :meaning, false
    change_column_null :wk_vocabs, :meaning_mnemonic, false
    change_column_null :wk_vocabs, :parts, false
    change_column_null :wk_vocabs, :reading, false
    change_column_null :wk_vocabs, :reading_mnemonic, false
  end
end
