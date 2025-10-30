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

ActiveRecord::Schema[8.1].define(version: 2025_10_14_140438) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "classifiers", force: :cascade do |t|
    t.string "category", limit: 100
    t.string "color", limit: 6
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "max_amount", precision: 8, scale: 2
    t.decimal "min_amount", precision: 8, scale: 2
    t.string "name", limit: 30
    t.datetime "updated_at", null: false
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", precision: nil, null: false
    t.date "date"
    t.string "source", limit: 50
    t.text "text"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "constellations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "iau", limit: 3
    t.string "name", limit: 30
    t.text "note"
    t.integer "stars_count", default: 0
    t.datetime "updated_at", null: false
    t.string "wikipedia", limit: 30
  end

  create_table "favourites", id: :serial, force: :cascade do |t|
    t.integer "category", limit: 2
    t.datetime "created_at", precision: nil, null: false
    t.string "link", limit: 200
    t.integer "mark", limit: 2, default: 0
    t.string "name", limit: 50
    t.text "note"
    t.integer "sandra", limit: 2, default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year"
  end

  create_table "flats", id: :serial, force: :cascade do |t|
    t.integer "bay", limit: 2
    t.integer "block", limit: 2
    t.integer "building", limit: 2
    t.string "category", limit: 7
    t.datetime "created_at", precision: nil, null: false
    t.string "name", limit: 10
    t.text "notes"
    t.integer "number", limit: 2
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "grammar_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", limit: 256
    t.datetime "updated_at", null: false
  end

  create_table "grammar_groups_grammars", id: false, force: :cascade do |t|
    t.bigint "grammar_group_id"
    t.bigint "grammar_id"
    t.index ["grammar_group_id"], name: "index_grammar_groups_grammars_on_grammar_group_id"
    t.index ["grammar_id"], name: "index_grammar_groups_grammars_on_grammar_id"
  end

  create_table "grammars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "eregexp", limit: 64
    t.integer "examples", default: [], array: true
    t.string "jregexp", limit: 64
    t.integer "last_example_checked", default: 0
    t.integer "level", limit: 2, default: 5
    t.text "note"
    t.string "ref", limit: 10
    t.string "title", limit: 128
    t.datetime "updated_at", null: false
  end

  create_table "logins", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "email", limit: 75
    t.string "ip", limit: 39
    t.boolean "success"
  end

  create_table "mass_events", force: :cascade do |t|
    t.string "code", limit: 16
    t.datetime "created_at", null: false
    t.date "finish"
    t.string "name", limit: 32
    t.date "start"
    t.datetime "updated_at", null: false
  end

  create_table "masses", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.date "date"
    t.decimal "finish", precision: 4, scale: 1
    t.decimal "start", precision: 4, scale: 1
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "matches", force: :cascade do |t|
    t.integer "away_score", limit: 2
    t.bigint "away_team_id", null: false
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "home_score", limit: 2
    t.bigint "home_team_id", null: false
    t.integer "season", limit: 2
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
  end

  create_table "misas", force: :cascade do |t|
    t.string "alt", limit: 256
    t.datetime "created_at", precision: nil, null: false
    t.boolean "japanese", default: false
    t.integer "lines", limit: 2, default: 0
    t.string "minutes", limit: 6
    t.text "note"
    t.integer "number", limit: 2
    t.date "published"
    t.string "series", limit: 16
    t.string "title", limit: 150
    t.datetime "updated_at", precision: nil, null: false
    t.string "url", limit: 256
  end

  create_table "notes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "number", limit: 2
    t.string "series", limit: 50
    t.text "stuff"
    t.string "title", limit: 150
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "partnerships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "divorce", limit: 2
    t.boolean "divorce_guess", default: false
    t.integer "husband_id"
    t.boolean "marriage", default: true
    t.integer "realm", limit: 2, default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.integer "wedding", limit: 2
    t.boolean "wedding_guess", default: false
    t.integer "wife_id"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.integer "born", limit: 2
    t.boolean "born_guess", default: false
    t.datetime "created_at", precision: nil, null: false
    t.boolean "default", default: false
    t.integer "died", limit: 2
    t.boolean "died_guess", default: false
    t.integer "father_id"
    t.string "first_names", limit: 100
    t.string "known_as", limit: 20
    t.string "last_name", limit: 50
    t.boolean "male"
    t.string "married_name", limit: 50
    t.integer "mother_id"
    t.text "notes"
    t.integer "realm", limit: 2, default: 0
    t.text "sensitive"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "people_pictures", id: false, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "picture_id", null: false
    t.index ["person_id"], name: "index_people_pictures_on_person_id"
    t.index ["picture_id"], name: "index_people_pictures_on_picture_id"
  end

  create_table "pictures", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "image", limit: 20
    t.datetime "image_updated_at", precision: nil
    t.boolean "portrait", default: false
    t.integer "realm", limit: 2, default: 0
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "places", force: :cascade do |t|
    t.boolean "capital", default: false
    t.string "category", limit: 10
    t.datetime "created_at", null: false
    t.string "ename", limit: 30
    t.string "jname", limit: 30
    t.string "mark_position", limit: 10
    t.text "notes"
    t.bigint "parent_id"
    t.integer "pop", limit: 2
    t.string "reading", limit: 30
    t.string "text_position", limit: 10
    t.datetime "updated_at", null: false
    t.string "vbox", limit: 20
    t.string "wiki", limit: 50
    t.index ["parent_id"], name: "index_places_on_parent_id"
  end

  create_table "returns", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.decimal "percent", precision: 4, scale: 1
    t.integer "returnable_id"
    t.string "returnable_type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year", limit: 2
    t.index ["returnable_type", "returnable_id"], name: "index_returns_on_returnable_type_and_returnable_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "stars", force: :cascade do |t|
    t.string "alpha", limit: 6
    t.string "bayer", limit: 3
    t.integer "components", limit: 2, default: 1
    t.bigint "constellation_id"
    t.datetime "created_at", null: false
    t.string "delta", limit: 7
    t.integer "distance"
    t.decimal "luminosity", precision: 10, scale: 2
    t.decimal "magnitude", precision: 4, scale: 2
    t.decimal "mass", precision: 6, scale: 2
    t.string "name", limit: 40
    t.text "note"
    t.decimal "radius", precision: 6, scale: 2
    t.integer "rank", limit: 2
    t.string "spectrum", limit: 16
    t.integer "temperature"
    t.datetime "updated_at", null: false
    t.string "wikipedia", limit: 40
    t.index ["constellation_id"], name: "index_stars_on_constellation_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "amount"
    t.datetime "created_at", null: false
    t.integer "frequency", limit: 2, default: 12
    t.string "payee"
    t.string "source"
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "fd_id"
    t.integer "fwp_id"
    t.string "name", limit: 30
    t.string "short", limit: 15
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string "account", limit: 4
    t.decimal "amount", precision: 8, scale: 2
    t.boolean "approved", default: false
    t.decimal "balance", precision: 8, scale: 2
    t.string "category", limit: 3
    t.bigint "classifier_id"
    t.datetime "created_at", null: false
    t.date "date"
    t.string "description", limit: 100
    t.datetime "updated_at", null: false
    t.integer "upload_id"
    t.index ["classifier_id"], name: "index_transactions_on_classifier_id"
  end

  create_table "tutorials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.boolean "draft", default: true
    t.text "notes"
    t.string "summary", limit: 100
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "email", limit: 75
    t.string "first_name", limit: 25
    t.string "last_name", limit: 25
    t.integer "last_otp_at"
    t.boolean "otp_required", default: false
    t.string "otp_secret", limit: 32
    t.string "password_digest"
    t.string "role", limit: 20
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "wk_audios", force: :cascade do |t|
    t.integer "audible_id"
    t.string "audible_type"
    t.string "file", limit: 64
  end

  create_table "wk_combos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "en", limit: 128
    t.string "ja", limit: 128
    t.datetime "updated_at", null: false
    t.bigint "vocab_id"
    t.index ["vocab_id"], name: "index_wk_combos_on_vocab_id"
  end

  create_table "wk_examples", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "day"
    t.string "english", limit: 200
    t.string "japanese", limit: 200
    t.datetime "updated_at", null: false
  end

  create_table "wk_examples_vocabs", force: :cascade do |t|
    t.bigint "example_id", null: false
    t.bigint "vocab_id", null: false
    t.index ["example_id"], name: "index_wk_examples_vocabs_on_example_id"
    t.index ["vocab_id"], name: "index_wk_examples_vocabs_on_vocab_id"
  end

  create_table "wk_groups", force: :cascade do |t|
    t.string "category", limit: 20
    t.datetime "created_at", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.string "vocab_list", limit: 200
  end

  create_table "wk_groups_vocabs", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "vocab_id", null: false
    t.index ["group_id"], name: "index_wk_groups_vocabs_on_group_id"
    t.index ["vocab_id"], name: "index_wk_groups_vocabs_on_vocab_id"
  end

  create_table "wk_kanas", force: :cascade do |t|
    t.integer "accent_pattern", limit: 2
    t.integer "accent_position", limit: 2
    t.string "characters", limit: 24
    t.datetime "created_at", null: false
    t.boolean "hidden", default: false
    t.date "last_updated"
    t.integer "level", limit: 2
    t.string "meaning", limit: 256
    t.text "meaning_mnemonic"
    t.text "notes"
    t.string "parts", limit: 80
    t.datetime "updated_at", null: false
    t.integer "wk_id", default: 0
  end

  create_table "wk_kanjis", force: :cascade do |t|
    t.string "character", limit: 1
    t.boolean "hidden", default: false
    t.text "kvg_frames"
    t.string "kvg_id"
    t.text "kvg_xml"
    t.date "last_updated"
    t.integer "level", limit: 2
    t.string "meaning", limit: 128
    t.text "meaning_mnemonic"
    t.string "reading", limit: 128
    t.text "reading_mnemonic"
    t.integer "wk_id"
    t.index ["wk_id"], name: "index_wk_kanjis_on_wk_id", unique: true
  end

  create_table "wk_kanjis_kanjis", id: false, force: :cascade do |t|
    t.integer "kanji_id"
    t.integer "similar_id"
    t.boolean "wk", default: true
    t.index ["kanji_id"], name: "index_wk_kanjis_kanjis_on_kanji_id"
    t.index ["similar_id"], name: "index_wk_kanjis_kanjis_on_similar_id"
  end

  create_table "wk_kanjis_radicals", id: false, force: :cascade do |t|
    t.bigint "kanji_id", null: false
    t.bigint "radical_id", null: false
    t.index ["kanji_id"], name: "index_wk_kanjis_radicals_on_kanji_id"
    t.index ["radical_id"], name: "index_wk_kanjis_radicals_on_radical_id"
  end

  create_table "wk_radicals", force: :cascade do |t|
    t.string "character", limit: 1
    t.boolean "hidden", default: false
    t.date "last_updated"
    t.integer "level", limit: 2
    t.text "mnemonic"
    t.string "name", limit: 32
    t.integer "wk_id"
    t.index ["wk_id"], name: "index_wk_radicals_on_wk_id", unique: true
  end

  create_table "wk_readings", force: :cascade do |t|
    t.integer "accent_pattern", limit: 2
    t.integer "accent_position", limit: 2
    t.string "characters", limit: 24
    t.boolean "primary"
    t.integer "vocab_id"
    t.index ["vocab_id"], name: "index_wk_readings_on_vocab_id"
  end

  create_table "wk_verb_pairs", force: :cascade do |t|
    t.string "category", limit: 10
    t.integer "intransitive_id"
    t.string "intransitive_suffix", limit: 6
    t.string "tag", limit: 5000
    t.integer "transitive_id"
    t.string "transitive_suffix", limit: 6
    t.index ["intransitive_id"], name: "index_wk_verb_pairs_on_intransitive_id"
    t.index ["tag"], name: "index_wk_verb_pairs_on_tag"
    t.index ["transitive_id", "intransitive_id"], name: "index_wk_verb_pairs_on_transitive_id_and_intransitive_id"
    t.index ["transitive_id"], name: "index_wk_verb_pairs_on_transitive_id"
  end

  create_table "wk_vocabs", force: :cascade do |t|
    t.string "characters", limit: 24
    t.integer "combos_count", default: 0, null: false
    t.boolean "hidden", default: false
    t.datetime "last_noted", precision: nil
    t.date "last_updated"
    t.integer "level", limit: 2
    t.string "meaning", limit: 256
    t.text "meaning_mnemonic"
    t.text "notes"
    t.string "parts", limit: 80
    t.string "reading", limit: 48
    t.text "reading_mnemonic"
    t.integer "wk_id"
    t.index ["wk_id"], name: "index_wk_vocabs_on_wk_id", unique: true
  end

  create_table "yomis", force: :cascade do |t|
    t.boolean "important", default: true
    t.bigint "kanji_id"
    t.boolean "on", default: true
    t.bigint "reading_id"
    t.index ["kanji_id"], name: "index_yomis_on_kanji_id"
    t.index ["reading_id"], name: "index_yomis_on_reading_id"
  end

  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
  add_foreign_key "places", "places", column: "parent_id"
  add_foreign_key "stars", "constellations"
end
