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

ActiveRecord::Schema.define(version: 20140601040325) do

  create_table "bongday_sleeps", force: true do |t|
    t.datetime "time_begin"
    t.datetime "time_end"
    t.integer  "bong_type"
    t.integer  "dsnum"
    t.integer  "lsnum"
    t.integer  "wakenum"
    t.integer  "waketimes"
    t.integer  "score"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bongday_sleeps", ["user_id"], name: "index_bongday_sleeps_on_user_id"

  create_table "match_users", force: true do |t|
    t.integer  "origin_id"
    t.integer  "matcher_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "match_users", ["origin_id", "matcher_id", "score"], name: "index_match_users_on_origin_id_and_matcher_id_and_score"

  create_table "users", force: true do |t|
    t.string   "name"
    t.integer  "gender"
    t.integer  "brithday"
    t.integer  "weight"
    t.integer  "height"
    t.integer  "targetsleeptime"
    t.integer  "targetCalorie"
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["uid"], name: "index_users_on_uid"

end
