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

ActiveRecord::Schema.define(version: 20150413125029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "funds", force: :cascade do |t|
    t.decimal  "annual_fee",                     precision: 3, scale: 2
    t.string   "category",            limit: 10
    t.string   "company",             limit: 50
    t.string   "name",                limit: 50
    t.boolean  "performance_fee"
    t.integer  "risk_reward_profile", limit: 2
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "sector",              limit: 40
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

  create_table "masses", force: :cascade do |t|
    t.date     "date"
    t.decimal  "start",      precision: 4, scale: 1
    t.decimal  "finish",     precision: 4, scale: 1
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
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

end
