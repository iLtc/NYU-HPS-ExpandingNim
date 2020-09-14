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

ActiveRecord::Schema.define(version: 2020_09_14_003256) do

  create_table "moves", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "session_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "stones_before"
    t.integer "stones_removed"
    t.integer "stones_after"
    t.integer "reset_before"
    t.boolean "reset"
    t.integer "reset_after"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_moves_on_session_id"
    t.index ["user_id"], name: "index_moves_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "status"
    t.integer "initial_stones"
    t.integer "left_stones"
    t.integer "current_max"
    t.boolean "reset"
    t.integer "accept_max_stones"
    t.integer "winner"
    t.integer "player_a_id"
    t.integer "player_b_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_a_id"], name: "index_sessions_on_player_a_id"
    t.index ["player_b_id"], name: "index_sessions_on_player_b_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.integer "left_resets"
    t.integer "left_time"
    t.datetime "start_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "moves", "sessions"
  add_foreign_key "moves", "users"
end
