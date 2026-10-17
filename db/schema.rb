# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_17_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "classifiers", force: :cascade do |t|
    t.string "category", limit: 100, null: false
    t.string "color", limit: 6, null: false
    t.text "description", null: false
    t.decimal "max_amount", precision: 8, scale: 2
    t.decimal "min_amount", precision: 8, scale: 2
    t.string "name", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_classifiers_on_lower_name", unique: true
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "source", limit: 50
    t.text "text"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "constellations", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "iau", limit: 3, null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stars_count", default: 0
    t.string "wikipedia", limit: 30
    t.index "lower((iau)::text)", name: "index_constellations_on_lower_iau", unique: true
    t.index "lower((name)::text)", name: "index_constellations_on_lower_name", unique: true
    t.index "lower((wikipedia)::text)", name: "index_constellations_on_lower_wikipedia", unique: true
  end

  create_table "favourites", id: :serial, force: :cascade do |t|
    t.integer "category", limit: 2
    t.string "name", limit: 50, null: false
    t.string "link", limit: 200
    t.integer "year"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "mark", limit: 2, default: 0
    t.integer "sandra", limit: 2, default: 0
    t.text "note", null: false
    t.index ["category", "name"], name: "index_favourites_on_category_and_name", unique: true
  end

  create_table "flats", id: :serial, force: :cascade do |t|
    t.integer "bay", limit: 2
    t.integer "block", limit: 2
    t.integer "building", limit: 2
    t.integer "number", limit: 2
    t.string "name", limit: 10
    t.string "category", limit: 7
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "notes"
    t.index ["bay"], name: "index_flats_on_bay", unique: true
    t.index ["building", "number"], name: "index_flats_on_building_and_number", unique: true
  end

  create_table "grammar_groups", force: :cascade do |t|
    t.string "title", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_grammar_groups_on_title", unique: true
  end

  create_table "grammar_groups_grammars", id: false, force: :cascade do |t|
    t.bigint "grammar_id"
    t.bigint "grammar_group_id"
    t.index ["grammar_group_id"], name: "index_grammar_groups_grammars_on_grammar_group_id"
    t.index ["grammar_id", "grammar_group_id"], name: "idx_on_grammar_id_grammar_group_id_0438847658", unique: true
  end

  create_table "grammars", force: :cascade do |t|
    t.string "title", limit: 128, null: false
    t.string "jregexp", limit: 64
    t.integer "level", limit: 2, default: 5
    t.integer "examples", default: [], array: true
    t.integer "last_example_checked", default: 0
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "eregexp", limit: 64
    t.string "ref", limit: 10
    t.index ["ref"], name: "index_grammars_on_ref", unique: true
    t.index ["title"], name: "index_grammars_on_title", unique: true
  end

  create_table "logins", id: :serial, force: :cascade do |t|
    t.string "email", limit: 75
    t.string "ip", limit: 39
    t.boolean "success"
    t.datetime "created_at", precision: nil, null: false
  end

  create_table "mass_events", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.date "start", null: false
    t.date "finish", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", limit: 16, null: false
    t.index ["finish"], name: "index_mass_events_on_finish", unique: true
    t.index ["start"], name: "index_mass_events_on_start", unique: true
  end

  create_table "masses", id: :serial, force: :cascade do |t|
    t.date "date", null: false
    t.decimal "start", precision: 4, scale: 1
    t.decimal "finish", precision: 4, scale: 1
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "start_2", precision: 4, scale: 1
    t.decimal "finish_2", precision: 4, scale: 1
    t.index ["date"], name: "index_masses_on_date", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "home_team_id", null: false
    t.bigint "away_team_id", null: false
    t.integer "home_score", limit: 2
    t.integer "away_score", limit: 2
    t.integer "season", limit: 2
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["home_team_id", "date"], name: "index_matches_on_home_team_id_and_date", unique: true
    t.index ["season", "away_team_id", "home_team_id"], name: "index_matches_on_season_and_away_team_id_and_home_team_id", unique: true
  end

  create_table "misas", force: :cascade do |t|
    t.boolean "japanese", default: false
    t.string "minutes", limit: 6
    t.text "note"
    t.string "title", limit: 150, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "lines", limit: 2, default: 0
    t.date "published"
    t.string "url", limit: 256
    t.string "alt", limit: 256
    t.string "series", limit: 16
    t.integer "number", limit: 2
    t.index ["alt"], name: "index_misas_on_alt", unique: true
    t.index ["series", "number"], name: "index_misas_on_series_and_number", unique: true
    t.index ["url"], name: "index_misas_on_url", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.text "stuff", null: false
    t.string "title", limit: 150, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "series", limit: 50
    t.integer "number", limit: 2
    t.index ["series", "number"], name: "index_notes_on_series_and_number", unique: true
  end

  create_table "partnerships", id: :serial, force: :cascade do |t|
    t.integer "divorce", limit: 2
    t.integer "husband_id", null: false
    t.integer "wedding", limit: 2, null: false
    t.integer "wife_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "marriage", default: true
    t.boolean "wedding_guess", default: false
    t.boolean "divorce_guess", default: false
    t.integer "realm", limit: 2, default: 0
    t.index ["wife_id", "husband_id"], name: "index_partnerships_on_wife_id_and_husband_id", unique: true
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.integer "born", limit: 2
    t.integer "died", limit: 2
    t.string "first_names", limit: 100, null: false
    t.boolean "male"
    t.string "last_name", limit: 50, null: false
    t.text "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "known_as", limit: 20, null: false
    t.integer "father_id"
    t.integer "mother_id"
    t.string "married_name", limit: 50
    t.boolean "born_guess", default: false
    t.boolean "died_guess", default: false
    t.integer "realm", limit: 2, default: 0
    t.text "sensitive"
    t.boolean "default", default: false
  end

  create_table "people_pictures", id: false, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "picture_id", null: false
    t.index ["person_id", "picture_id"], name: "index_people_pictures_on_person_id_and_picture_id", unique: true
    t.index ["picture_id"], name: "index_people_pictures_on_picture_id"
  end

  create_table "pictures", id: :serial, force: :cascade do |t|
    t.datetime "image_updated_at", precision: nil
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "portrait", default: false
    t.string "title"
    t.integer "realm", limit: 2, default: 0
    t.string "image", limit: 20
    t.index ["image"], name: "index_pictures_on_image", unique: true
  end

  create_table "places", force: :cascade do |t|
    t.string "ename", limit: 30, null: false
    t.string "jname", limit: 30, null: false
    t.string "reading", limit: 30, null: false
    t.string "wiki", limit: 50, null: false
    t.string "category", limit: 10
    t.integer "pop", limit: 2
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "vbox", limit: 17
    t.boolean "capital", default: false
    t.text "notes"
    t.string "mark_position", limit: 9
    t.string "text_position", limit: 9
    t.index ["ename"], name: "index_places_on_ename", unique: true
    t.index ["jname"], name: "index_places_on_jname", unique: true
    t.index ["parent_id"], name: "index_places_on_parent_id"
    t.index ["vbox"], name: "index_places_on_vbox", unique: true
    t.index ["wiki"], name: "index_places_on_wiki", unique: true
  end

  create_table "pp_prices", force: :cascade do |t|
    t.bigint "station_id", null: false
    t.decimal "price_pence", precision: 5, scale: 1, null: false
    t.datetime "price_last_updated", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["station_id", "price_last_updated"], name: "index_pp_prices_on_station_id_and_price_last_updated"
  end

  create_table "pp_stations", force: :cascade do |t|
    t.string "node_id", limit: 64, null: false
    t.string "name", limit: 75, null: false
    t.string "brand", limit: 30
    t.string "address", limit: 50
    t.string "postcode", limit: 10
    t.decimal "latitude", precision: 10, scale: 7, null: false
    t.decimal "longitude", precision: 10, scale: 7, null: false
    t.string "preferred_name", limit: 75
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "colour", limit: 6, default: "888888", null: false
    t.index ["node_id"], name: "index_pp_stations_on_node_id", unique: true
    t.index ["preferred_name"], name: "index_pp_stations_on_preferred_name", unique: true
  end

  create_table "pp_sync_logs", force: :cascade do |t|
    t.string "query_type", limit: 25, null: false
    t.integer "records_scanned", default: 0, null: false
    t.integer "records_created", default: 0, null: false
    t.integer "records_updated", default: 0, null: false
    t.integer "records_unchanged", default: 0, null: false
    t.text "error_message"
    t.datetime "started_at", null: false
    t.decimal "duration_seconds", precision: 8, scale: 2
    t.integer "records_matched", default: 0, null: false
    t.index ["query_type", "started_at"], name: "index_pp_sync_logs_on_query_type_and_started_at"
  end

  create_table "returns", id: :serial, force: :cascade do |t|
    t.integer "year", limit: 2
    t.decimal "percent", precision: 4, scale: 1
    t.integer "returnable_id"
    t.string "returnable_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["returnable_type", "returnable_id"], name: "index_returns_on_returnable_type_and_returnable_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "stars", force: :cascade do |t|
    t.string "name", limit: 40, null: false
    t.integer "distance"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alpha", limit: 6
    t.string "delta", limit: 7
    t.decimal "magnitude", precision: 4, scale: 2
    t.bigint "constellation_id"
    t.decimal "mass", precision: 6, scale: 2
    t.string "bayer", limit: 3
    t.integer "components", limit: 2, default: 1
    t.decimal "radius", precision: 6, scale: 2
    t.string "wikipedia", limit: 40
    t.decimal "luminosity", precision: 10, scale: 2
    t.integer "temperature"
    t.string "spectrum", limit: 16, null: false
    t.integer "rank", limit: 2
    t.index "lower((name)::text)", name: "index_stars_on_lower_name", unique: true
    t.index "lower((wikipedia)::text)", name: "index_stars_on_lower_wikipedia", unique: true
    t.index ["constellation_id", "bayer"], name: "index_stars_on_constellation_id_and_bayer", unique: true
    t.index ["rank"], name: "index_stars_on_rank", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "payee", limit: 50, null: false
    t.integer "amount", null: false
    t.integer "frequency", limit: 2, default: 12
    t.string "source", limit: 40, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["payee"], name: "index_subscriptions_on_payee", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "short", limit: 15, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fd_id"
    t.integer "fwp_id"
    t.index ["name"], name: "index_teams_on_name", unique: true
    t.index ["short"], name: "index_teams_on_short", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date", null: false
    t.string "category", limit: 3
    t.string "description", limit: 100, null: false
    t.decimal "amount", precision: 8, scale: 2
    t.decimal "balance", precision: 8, scale: 2
    t.string "account", limit: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "upload_id"
    t.bigint "classifier_id"
    t.boolean "approved", default: false
    t.index ["classifier_id"], name: "index_transactions_on_classifier_id"
    t.index ["upload_id"], name: "index_transactions_on_upload_id"
  end

  create_table "tutorials", force: :cascade do |t|
    t.date "date"
    t.string "summary", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.boolean "draft", default: true
    t.index ["date"], name: "index_tutorials_on_date", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 75
    t.string "role", limit: 20
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "first_name", limit: 25, null: false
    t.string "last_name", limit: 25, null: false
    t.boolean "otp_required", default: false
    t.string "otp_secret", limit: 32
    t.integer "last_otp_at"
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wk_audios", force: :cascade do |t|
    t.string "file", limit: 64, null: false
    t.integer "audible_id"
    t.string "audible_type"
    t.index ["audible_type", "audible_id"], name: "index_wk_audios_on_audible_type_and_audible_id"
    t.index ["file"], name: "index_wk_audios_on_file", unique: true
  end

  create_table "wk_combos", force: :cascade do |t|
    t.bigint "vocab_id"
    t.string "ja", limit: 128, null: false
    t.string "en", limit: 128, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vocab_id"], name: "index_wk_combos_on_vocab_id"
  end

  create_table "wk_examples", force: :cascade do |t|
    t.string "japanese", limit: 200, null: false
    t.string "english", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "day"
  end

  create_table "wk_examples_vocabs", force: :cascade do |t|
    t.bigint "example_id", null: false
    t.bigint "vocab_id", null: false
    t.index ["example_id", "vocab_id"], name: "index_wk_examples_vocabs_on_example_id_and_vocab_id", unique: true
    t.index ["vocab_id"], name: "index_wk_examples_vocabs_on_vocab_id"
  end

  create_table "wk_groups", force: :cascade do |t|
    t.string "category", limit: 20
    t.string "vocab_list", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
  end

  create_table "wk_groups_vocabs", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "vocab_id", null: false
    t.index ["group_id", "vocab_id"], name: "index_wk_groups_vocabs_on_group_id_and_vocab_id", unique: true
    t.index ["vocab_id"], name: "index_wk_groups_vocabs_on_vocab_id"
  end

  create_table "wk_kanas", force: :cascade do |t|
    t.string "characters", limit: 24, null: false
    t.boolean "hidden", default: false
    t.date "last_updated"
    t.integer "level", limit: 2
    t.string "meaning", limit: 256, null: false
    t.text "meaning_mnemonic", null: false
    t.text "notes"
    t.integer "wk_id", default: 0
    t.string "parts", limit: 80, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "accent_position", limit: 2
    t.integer "accent_pattern", limit: 2
    t.index ["characters"], name: "index_wk_kanas_on_characters", unique: true
    t.index ["wk_id"], name: "index_wk_kanas_on_wk_id", unique: true
  end

  create_table "wk_kanjis", force: :cascade do |t|
    t.integer "wk_id"
    t.integer "level", limit: 2
    t.string "character", limit: 1
    t.string "meaning", limit: 128, null: false
    t.text "meaning_mnemonic", null: false
    t.text "reading_mnemonic", null: false
    t.date "last_updated", null: false
    t.string "reading", limit: 128, null: false
    t.string "kvg_id"
    t.text "kvg_xml"
    t.text "kvg_frames"
    t.boolean "hidden", default: false
    t.datetime "favourite"
    t.datetime "former_favourite"
    t.index ["character"], name: "index_wk_kanjis_on_character", unique: true
    t.index ["wk_id"], name: "index_wk_kanjis_on_wk_id", unique: true
  end

  create_table "wk_kanjis_kanjis", id: false, force: :cascade do |t|
    t.integer "kanji_id"
    t.integer "similar_id"
    t.boolean "wk", default: true
    t.index ["kanji_id", "similar_id"], name: "index_wk_kanjis_kanjis_on_kanji_id_and_similar_id", unique: true
    t.index ["similar_id"], name: "index_wk_kanjis_kanjis_on_similar_id"
  end

  create_table "wk_kanjis_radicals", id: false, force: :cascade do |t|
    t.bigint "kanji_id", null: false
    t.bigint "radical_id", null: false
    t.index ["kanji_id", "radical_id"], name: "index_wk_kanjis_radicals_on_kanji_id_and_radical_id", unique: true
    t.index ["radical_id"], name: "index_wk_kanjis_radicals_on_radical_id"
  end

  create_table "wk_radicals", force: :cascade do |t|
    t.integer "wk_id"
    t.integer "level", limit: 2
    t.text "mnemonic", null: false
    t.string "name", limit: 32, null: false
    t.string "character", limit: 1
    t.date "last_updated", null: false
    t.boolean "hidden", default: false
    t.index ["character"], name: "index_wk_radicals_on_character", unique: true
    t.index ["name"], name: "index_wk_radicals_on_name", unique: true
    t.index ["wk_id"], name: "index_wk_radicals_on_wk_id", unique: true
  end

  create_table "wk_readings", force: :cascade do |t|
    t.integer "accent_pattern", limit: 2
    t.integer "accent_position", limit: 2
    t.string "characters", limit: 24, null: false
    t.boolean "primary"
    t.bigint "vocab_id"
    t.index ["vocab_id"], name: "index_wk_readings_on_vocab_id"
  end

  create_table "wk_verb_pairs", force: :cascade do |t|
    t.string "category", limit: 10
    t.string "tag", limit: 5000
    t.bigint "transitive_id"
    t.bigint "intransitive_id"
    t.string "transitive_suffix", limit: 6, null: false
    t.string "intransitive_suffix", limit: 6, null: false
    t.index ["intransitive_id"], name: "index_wk_verb_pairs_on_intransitive_id"
    t.index ["tag"], name: "index_wk_verb_pairs_on_tag"
    t.index ["transitive_id", "intransitive_id"], name: "index_wk_verb_pairs_on_transitive_id_and_intransitive_id", unique: true
  end

  create_table "wk_vocabs", force: :cascade do |t|
    t.string "characters", limit: 24, null: false
    t.date "last_updated"
    t.integer "level", limit: 2
    t.string "meaning", limit: 256, null: false
    t.text "meaning_mnemonic", null: false
    t.string "parts", limit: 80, null: false
    t.string "reading", limit: 48, null: false
    t.text "reading_mnemonic", null: false
    t.integer "wk_id"
    t.text "notes"
    t.datetime "last_noted", precision: nil
    t.boolean "hidden", default: false
    t.integer "combos_count", default: 0, null: false
    t.index ["characters"], name: "index_wk_vocabs_on_characters", unique: true
    t.index ["wk_id"], name: "index_wk_vocabs_on_wk_id", unique: true
  end

  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
  add_foreign_key "partnerships", "people", column: "husband_id"
  add_foreign_key "partnerships", "people", column: "wife_id"
  add_foreign_key "people", "people", column: "father_id"
  add_foreign_key "people", "people", column: "mother_id"
  add_foreign_key "places", "places", column: "parent_id"
  add_foreign_key "pp_prices", "pp_stations", column: "station_id"
  add_foreign_key "stars", "constellations"
  add_foreign_key "transactions", "classifiers"
  add_foreign_key "wk_combos", "wk_vocabs", column: "vocab_id"
  add_foreign_key "wk_readings", "wk_vocabs", column: "vocab_id"
  add_foreign_key "wk_verb_pairs", "wk_vocabs", column: "intransitive_id"
  add_foreign_key "wk_verb_pairs", "wk_vocabs", column: "transitive_id"
end
