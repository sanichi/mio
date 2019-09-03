# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_02_155622) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "blogs", id: :serial, force: :cascade do |t|
    t.text "story"
    t.string "title", limit: 150
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "draft", default: true
  end

  create_table "books", force: :cascade do |t|
    t.string "author", limit: 60
    t.string "category", limit: 10
    t.string "medium", limit: 10
    t.text "note"
    t.string "title", limit: 100
    t.integer "year", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "borrower", limit: 30
  end

  create_table "buckets", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50
    t.text "notes"
    t.integer "mark", limit: 2, default: 0
    t.integer "sandra", limit: 2, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "source", limit: 50
    t.text "text"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "audio", limit: 50
    t.text "story"
    t.string "title", limit: 150
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dragons", force: :cascade do |t|
    t.boolean "male", default: true
    t.string "first_name", limit: 15
    t.string "last_name", limit: 20
  end

  create_table "expenses", id: :serial, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.string "category", limit: 10
    t.string "description", limit: 60
    t.string "period", limit: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favourites", id: :serial, force: :cascade do |t|
    t.integer "category", limit: 2
    t.string "name", limit: 50
    t.string "link", limit: 200
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mark", limit: 2, default: 0
    t.integer "sandra", limit: 2, default: 0
    t.text "note"
  end

  create_table "flats", id: :serial, force: :cascade do |t|
    t.integer "bay", limit: 2
    t.integer "block", limit: 2
    t.integer "building", limit: 2
    t.integer "number", limit: 2
    t.string "name", limit: 10
    t.string "category", limit: 7
    t.integer "owner_id"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "landlord_id"
    t.text "notes"
  end

  create_table "funds", id: :serial, force: :cascade do |t|
    t.decimal "annual_fee", precision: 3, scale: 2
    t.string "category", limit: 10
    t.string "company", limit: 50
    t.string "name", limit: 70
    t.boolean "performance_fee"
    t.integer "srri", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sector", limit: 40
    t.integer "size"
    t.string "stars"
    t.boolean "srri_estimated", default: false
  end

  create_table "historical_events", id: :serial, force: :cascade do |t|
    t.integer "start", limit: 2
    t.integer "finish", limit: 2
    t.string "description", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incomes", id: :serial, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.string "category", limit: 10
    t.string "description", limit: 60
    t.string "period", limit: 10
    t.date "start"
    t.date "finish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "joint", limit: 2, default: 100
  end

  create_table "interfaces", id: :serial, force: :cascade do |t|
    t.string "mac_address", limit: 17
    t.integer "device_id"
    t.string "name", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip_address", limit: 15
    t.string "manufacturer", limit: 50
  end

  create_table "kanji_questions", force: :cascade do |t|
    t.integer "kanji_id"
    t.integer "kanji_test_id"
    t.boolean "answer", default: false
    t.datetime "created_at"
    t.index ["kanji_id"], name: "index_kanji_questions_on_kanji_id"
    t.index ["kanji_test_id"], name: "index_kanji_questions_on_kanji_test_id"
  end

  create_table "kanji_tests", force: :cascade do |t|
    t.integer "attempts", limit: 2, default: 0
    t.integer "correct", limit: 2, default: 0
    t.integer "hit_rate", limit: 2, default: 0
    t.integer "level", limit: 2
    t.integer "progress_rate", limit: 2, default: 0
    t.integer "total", limit: 2, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kanjis", force: :cascade do |t|
    t.string "symbol", limit: 1
    t.integer "onyomi", default: 0
    t.integer "kunyomi", default: 0
    t.string "meaning", limit: 100
    t.integer "level", limit: 2
    t.boolean "burned", default: false
    t.integer "frequency", limit: 2, default: 0
    t.index ["meaning"], name: "index_kanjis_on_meaning"
    t.index ["symbol"], name: "index_kanjis_on_symbol"
  end

  create_table "lessons", force: :cascade do |t|
    t.string "chapter", limit: 60
    t.integer "chapter_no", limit: 2
    t.integer "complete", limit: 2, default: 0
    t.string "link", limit: 200
    t.text "note"
    t.string "section", limit: 50
    t.string "series", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "book", limit: 200
    t.string "eco", limit: 20
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.string "url", limit: 256
    t.string "target", limit: 20, default: "external"
    t.string "text", limit: 50
    t.integer "linkable_id"
    t.string "linkable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id"
  end

  create_table "logins", id: :serial, force: :cascade do |t|
    t.string "email", limit: 75
    t.string "ip", limit: 39
    t.boolean "success"
    t.datetime "created_at"
  end

  create_table "masses", id: :serial, force: :cascade do |t|
    t.date "date"
    t.decimal "start", precision: 4, scale: 1
    t.decimal "finish", precision: 4, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "misas", force: :cascade do |t|
    t.string "category", limit: 10, default: "none"
    t.boolean "japanese", default: false
    t.string "minutes", limit: 6
    t.text "note"
    t.string "title", limit: 150
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lines", limit: 2, default: 0
    t.date "published"
    t.string "url", limit: 256
    t.string "alt", limit: 256
  end

  create_table "notes", force: :cascade do |t|
    t.text "stuff"
    t.string "title", limit: 150
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "occupations", force: :cascade do |t|
    t.string "kanji", limit: 20
    t.string "meaning", limit: 100
    t.string "reading", limit: 20
    t.integer "vocab_id"
  end

  create_table "openings", id: :serial, force: :cascade do |t|
    t.string "code", limit: 3
    t.string "description", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parkings", id: :serial, force: :cascade do |t|
    t.integer "vehicle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "noted_at"
    t.integer "bay", limit: 2
    t.index ["vehicle_id"], name: "index_parkings_on_vehicle_id"
  end

  create_table "partnerships", id: :serial, force: :cascade do |t|
    t.integer "divorce", limit: 2
    t.integer "husband_id"
    t.integer "wedding", limit: 2
    t.integer "wife_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "marriage", default: true
    t.boolean "wedding_guess", default: false
    t.boolean "divorce_guess", default: false
    t.integer "realm", limit: 2, default: 0
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.integer "born", limit: 2
    t.integer "died", limit: 2
    t.string "first_names", limit: 100
    t.boolean "male"
    t.string "last_name", limit: 50
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "known_as", limit: 20
    t.integer "father_id"
    t.integer "mother_id"
    t.string "married_name", limit: 50
    t.boolean "born_guess", default: false
    t.boolean "died_guess", default: false
    t.integer "realm", limit: 2, default: 0
  end

  create_table "people_pictures", id: false, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "picture_id", null: false
    t.index ["person_id"], name: "index_people_pictures_on_person_id"
    t.index ["picture_id"], name: "index_people_pictures_on_picture_id"
  end

  create_table "pictures", id: :serial, force: :cascade do |t|
    t.datetime "image_updated_at"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "portrait", default: false
    t.string "title"
    t.integer "realm", limit: 2, default: 0
  end

  create_table "positions", id: :serial, force: :cascade do |t|
    t.string "pieces", limit: 71
    t.string "active", limit: 1
    t.string "castling", limit: 4
    t.string "en_passant", limit: 2
    t.integer "half_move", limit: 2
    t.integer "move", limit: 2
    t.string "name", limit: 255
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "opening_id", limit: 2
    t.date "last_reviewed"
    t.string "opening_365", limit: 255
  end

  create_table "problems", force: :cascade do |t|
    t.integer "category", limit: 2
    t.integer "level", limit: 2
    t.text "note"
    t.integer "subcategory", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "audio", limit: 20
  end

  create_table "questions", force: :cascade do |t|
    t.string "question", limit: 255
    t.string "answer1", limit: 100
    t.string "answer2", limit: 100
    t.string "answer3", limit: 100
    t.string "answer4", limit: 100
    t.integer "solution", limit: 2
    t.text "note"
    t.integer "problem_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "audio", limit: 20
    t.index ["problem_id"], name: "index_questions_on_problem_id"
  end

  create_table "radicals", force: :cascade do |t|
    t.boolean "burned", default: false
    t.integer "level", limit: 2
    t.string "meaning", limit: 100
    t.string "symbol", limit: 1
    t.integer "kanji_id"
    t.string "old_meaning", limit: 100
  end

  create_table "readings", force: :cascade do |t|
    t.string "kana", limit: 5
    t.integer "onyomi", default: 0
    t.integer "kunyomi", default: 0
  end

  create_table "residents", id: :serial, force: :cascade do |t|
    t.string "first_names", limit: 100
    t.string "last_name", limit: 50
    t.string "email", limit: 75
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address", limit: 200
    t.string "agent", limit: 200
  end

  create_table "returns", id: :serial, force: :cascade do |t|
    t.integer "year", limit: 2
    t.decimal "percent", precision: 4, scale: 1
    t.integer "returnable_id"
    t.string "returnable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["returnable_type", "returnable_id"], name: "index_returns_on_returnable_type_and_returnable_id"
  end

  create_table "similar_kanjis", force: :cascade do |t|
    t.string "kanjis", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category", limit: 10
  end

  create_table "similar_words", force: :cascade do |t|
    t.string "readings", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tapas", id: :serial, force: :cascade do |t|
    t.string "title", limit: 50
    t.string "keywords", limit: 100
    t.integer "number", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "post_id", limit: 150
    t.text "notes"
    t.boolean "star", default: false
  end

  create_table "todos", id: :serial, force: :cascade do |t|
    t.string "description", limit: 60
    t.boolean "done", default: false
    t.integer "priority", limit: 2, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trades", id: :serial, force: :cascade do |t|
    t.string "stock", limit: 60
    t.decimal "units", precision: 10, scale: 3
    t.decimal "buy_price", precision: 9, scale: 2
    t.decimal "sell_price", precision: 9, scale: 2
    t.date "buy_date"
    t.date "sell_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "buy_factor", precision: 6, scale: 3, default: "1.0"
    t.decimal "sell_factor", precision: 6, scale: 3, default: "1.0"
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.decimal "cost", precision: 10, scale: 2
    t.datetime "created_at"
    t.string "description"
    t.integer "quantity"
    t.string "reference"
    t.date "settle_date"
    t.string "signature"
    t.date "trade_date"
    t.integer "upload_id"
    t.decimal "value", precision: 10, scale: 2
    t.string "account", limit: 3
    t.index ["signature"], name: "index_transactions_on_signature", unique: true
    t.index ["upload_id"], name: "index_transactions_on_upload_id"
  end

  create_table "uploads", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "content_type"
    t.string "error"
    t.string "name"
    t.integer "size"
    t.datetime "created_at"
    t.string "account", limit: 3
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 75
    t.string "encrypted_password", limit: 32
    t.string "role", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "person_id"
  end

  create_table "vehicles", id: :serial, force: :cascade do |t|
    t.integer "resident_id"
    t.string "registration", limit: 12
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description", limit: 20
  end

  create_table "verb_pairs", force: :cascade do |t|
    t.string "tag", limit: 285
    t.integer "transitive_id"
    t.integer "intransitive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group", limit: 2
    t.index ["group"], name: "index_verb_pairs_on_group"
    t.index ["intransitive_id"], name: "index_verb_pairs_on_intransitive_id"
    t.index ["tag"], name: "index_verb_pairs_on_tag"
    t.index ["transitive_id", "intransitive_id"], name: "index_verb_pairs_on_transitive_id_and_intransitive_id"
    t.index ["transitive_id"], name: "index_verb_pairs_on_transitive_id"
  end

  create_table "vocab_questions", force: :cascade do |t|
    t.integer "vocab_id"
    t.integer "vocab_test_id"
    t.string "kanji", limit: 20
    t.string "meaning", limit: 100
    t.string "reading", limit: 20
    t.boolean "kanji_correct", default: false
    t.boolean "meaning_correct", default: false
    t.boolean "reading_correct", default: false
    t.datetime "created_at"
    t.index ["vocab_id"], name: "index_vocab_questions_on_vocab_id"
    t.index ["vocab_test_id"], name: "index_vocab_questions_on_vocab_test_id"
  end

  create_table "vocab_tests", force: :cascade do |t|
    t.integer "total", limit: 2, default: 0
    t.integer "level", limit: 2
    t.string "category", limit: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attempts", limit: 2, default: 0
    t.integer "correct", limit: 2, default: 0
    t.integer "hit_rate", limit: 2, default: 0
    t.integer "progress_rate", limit: 2, default: 0
  end

  create_table "vocabs", id: :serial, force: :cascade do |t|
    t.string "audio", limit: 100
    t.string "reading", limit: 20
    t.string "kanji", limit: 20
    t.string "meaning", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level", limit: 2
    t.string "category", limit: 50
    t.integer "accent", limit: 2
    t.integer "pattern_no", limit: 2
    t.integer "morae", limit: 2, default: 0
    t.boolean "burned", default: false
    t.index ["meaning"], name: "index_vocabs_on_meaning"
    t.index ["reading"], name: "index_vocabs_on_reading"
  end

  create_table "wk_kanjis", force: :cascade do |t|
    t.string "character", limit: 1
    t.integer "level", limit: 2
    t.text "meaning_mnemonic"
    t.text "reading_mnemonic"
    t.integer "wk_id"
  end

  create_table "wk_radicals", force: :cascade do |t|
    t.integer "wk_id"
    t.integer "level", limit: 2
    t.text "mnemonic"
    t.string "name", limit: 32
    t.string "character", limit: 1
  end

  create_table "yomis", force: :cascade do |t|
    t.bigint "kanji_id"
    t.bigint "reading_id"
    t.boolean "on", default: true
    t.boolean "important", default: true
    t.index ["kanji_id"], name: "index_yomis_on_kanji_id"
    t.index ["reading_id"], name: "index_yomis_on_reading_id"
  end

end
