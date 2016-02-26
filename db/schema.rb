# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160225193941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bays", force: :cascade do |t|
    t.integer  "number",      limit: 2
    t.integer  "resident_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "blogs", force: :cascade do |t|
    t.text     "story"
    t.string   "title",      limit: 150
    t.integer  "user_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "draft",                  default: true
  end

  create_table "comments", force: :cascade do |t|
    t.date     "date"
    t.string   "source",           limit: 50
    t.text     "text"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree

  create_table "expenses", force: :cascade do |t|
    t.decimal  "amount",                 precision: 10, scale: 2
    t.string   "category",    limit: 10
    t.string   "description", limit: 60
    t.string   "period",      limit: 10
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "favourites", force: :cascade do |t|
    t.integer  "category",   limit: 2
    t.string   "name",       limit: 50
    t.string   "link",       limit: 100
    t.integer  "year"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "mark",       limit: 2,   default: 0
    t.integer  "sandra",     limit: 2,   default: 0
  end

  create_table "funds", force: :cascade do |t|
    t.decimal  "annual_fee",                 precision: 3, scale: 2
    t.string   "category",        limit: 10
    t.string   "company",         limit: 50
    t.string   "name",            limit: 70
    t.boolean  "performance_fee"
    t.integer  "srri",            limit: 2
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.string   "sector",          limit: 40
    t.integer  "size"
    t.string   "stars"
    t.boolean  "srri_estimated",                                     default: false
  end

  create_table "historical_events", force: :cascade do |t|
    t.integer  "start",       limit: 2
    t.integer  "finish",      limit: 2
    t.string   "description", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "incomes", force: :cascade do |t|
    t.decimal  "amount",                 precision: 10, scale: 2
    t.string   "category",    limit: 10
    t.string   "description", limit: 60
    t.string   "period",      limit: 10
    t.date     "start"
    t.date     "finish"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.integer  "joint",       limit: 2,                           default: 100
  end

  create_table "links", force: :cascade do |t|
    t.string   "url",           limit: 256
    t.string   "target",        limit: 20,  default: "external"
    t.string   "text",          limit: 50
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "links", ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id", using: :btree

  create_table "logins", force: :cascade do |t|
    t.string   "email",      limit: 75
    t.string   "ip",         limit: 39
    t.boolean  "success"
    t.datetime "created_at"
  end

  create_table "masses", force: :cascade do |t|
    t.date     "date"
    t.decimal  "start",      precision: 4, scale: 1
    t.decimal  "finish",     precision: 4, scale: 1
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "parkings", force: :cascade do |t|
    t.integer  "bay_id"
    t.integer  "vehicle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "parkings", ["bay_id"], name: "index_parkings_on_bay_id", using: :btree
  add_index "parkings", ["vehicle_id"], name: "index_parkings_on_vehicle_id", using: :btree

  create_table "partnerships", force: :cascade do |t|
    t.integer  "divorce",       limit: 2
    t.integer  "husband_id"
    t.integer  "wedding",       limit: 2
    t.integer  "wife_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "marriage",                default: true
    t.boolean  "wedding_guess",           default: false
    t.boolean  "divorce_guess",           default: false
  end

  create_table "people", force: :cascade do |t|
    t.integer  "born",         limit: 2
    t.integer  "died",         limit: 2
    t.string   "first_names",  limit: 100
    t.boolean  "male"
    t.string   "last_name",    limit: 50
    t.text     "notes"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "known_as",     limit: 20
    t.integer  "father_id"
    t.integer  "mother_id"
    t.string   "married_name", limit: 50
    t.boolean  "born_guess",               default: false
    t.boolean  "died_guess",               default: false
  end

  create_table "people_pictures", id: false, force: :cascade do |t|
    t.integer "person_id",  null: false
    t.integer "picture_id", null: false
  end

  add_index "people_pictures", ["person_id"], name: "index_people_pictures_on_person_id", using: :btree
  add_index "people_pictures", ["picture_id"], name: "index_people_pictures_on_picture_id", using: :btree

  create_table "pictures", force: :cascade do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "description"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "portrait",           default: false
    t.string   "title"
  end

  create_table "residents", force: :cascade do |t|
    t.integer  "block",       limit: 2
    t.integer  "flat",        limit: 2
    t.string   "first_names", limit: 100
    t.string   "last_name",   limit: 50
    t.string   "email",       limit: 75
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "returns", force: :cascade do |t|
    t.integer  "year",            limit: 2
    t.decimal  "percent",                   precision: 4, scale: 1
    t.integer  "returnable_id"
    t.string   "returnable_type"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "returns", ["returnable_type", "returnable_id"], name: "index_returns_on_returnable_type_and_returnable_id", using: :btree

  create_table "tapas", force: :cascade do |t|
    t.string   "title",      limit: 50
    t.string   "keywords",   limit: 100
    t.integer  "number",     limit: 2
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "post_id"
    t.text     "notes"
    t.boolean  "star",                   default: false
  end

  create_table "todos", force: :cascade do |t|
    t.string   "description", limit: 60
    t.boolean  "done",                   default: false
    t.integer  "priority",    limit: 2,  default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal  "cost",                  precision: 10, scale: 2
    t.datetime "created_at"
    t.string   "description"
    t.integer  "quantity"
    t.string   "reference"
    t.date     "settle_date"
    t.string   "signature"
    t.date     "trade_date"
    t.integer  "upload_id"
    t.decimal  "value",                 precision: 10, scale: 2
    t.string   "account",     limit: 3
  end

  add_index "transactions", ["signature"], name: "index_transactions_on_signature", unique: true, using: :btree
  add_index "transactions", ["upload_id"], name: "index_transactions_on_upload_id", using: :btree

  create_table "uploads", force: :cascade do |t|
    t.text     "content"
    t.string   "content_type"
    t.string   "error"
    t.string   "name"
    t.integer  "size"
    t.datetime "created_at"
    t.string   "account",      limit: 3
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",              limit: 75
    t.string   "encrypted_password", limit: 32
    t.string   "role",               limit: 20
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "person_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.integer  "resident_id"
    t.string   "registration", limit: 8
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
