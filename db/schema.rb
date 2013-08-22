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

ActiveRecord::Schema.define(version: 20130819230148) do

  create_table "stop_times", force: true do |t|
    t.integer  "stop_id"
    t.integer  "trip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stops", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trips", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vehicle_positions", force: true do |t|
    t.decimal  "lat",        precision: 10, scale: 7
    t.decimal  "lon",        precision: 10, scale: 7
    t.decimal  "bearing",    precision: 5,  scale: 2
    t.decimal  "odometer",   precision: 8,  scale: 2
    t.decimal  "speed",      precision: 4,  scale: 2
    t.datetime "timestamp"
    t.integer  "trip_id"
    t.integer  "vehicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vehicle_positions", ["trip_id"], name: "index_vehicle_positions_on_trip_id"
  add_index "vehicle_positions", ["vehicle_id"], name: "index_vehicle_positions_on_vehicle_id"

end
