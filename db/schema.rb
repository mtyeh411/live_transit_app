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

ActiveRecord::Schema.define(version: 20130315180000) do

  create_table "agencies", force: true do |t|
    t.string "agency_id"
    t.string "agency_name",     limit: 512,  null: false
    t.string "agency_url",      limit: 1024, null: false
    t.string "agency_timezone",              null: false
    t.string "agency_lang"
    t.string "agency_phone"
    t.string "agency_fare_url", limit: 1024
  end

  add_index "agencies", ["agency_id"], name: "index_agencies_on_agency_id", unique: true
  add_index "agencies", ["agency_name"], name: "index_agencies_on_agency_name"

  create_table "routes", force: true do |t|
    t.string  "route_id",                      null: false
    t.string  "agency_id"
    t.string  "route_short_name",              null: false
    t.string  "route_long_name",  limit: 1024, null: false
    t.text    "route_desc"
    t.integer "route_type",                    null: false
    t.string  "route_url",        limit: 1024
    t.string  "route_color"
    t.string  "route_text_color"
  end

  add_index "routes", ["agency_id"], name: "index_routes_on_agency_id"
  add_index "routes", ["route_id"], name: "index_routes_on_route_id", unique: true
  add_index "routes", ["route_long_name"], name: "index_routes_on_route_long_name"
  add_index "routes", ["route_short_name"], name: "index_routes_on_route_short_name"

  create_table "shape_points", force: true do |t|
    t.string  "shape_id",            null: false
    t.float   "shape_pt_lat",        null: false
    t.float   "shape_pt_lon",        null: false
    t.integer "shape_pt_sequence",   null: false
    t.float   "shape_dist_traveled"
  end

  add_index "shape_points", ["shape_id"], name: "index_shape_points_on_shape_id"
  add_index "shape_points", ["shape_pt_lat"], name: "index_shape_points_on_shape_pt_lat"
  add_index "shape_points", ["shape_pt_lon"], name: "index_shape_points_on_shape_pt_lon"
  add_index "shape_points", ["shape_pt_sequence"], name: "index_shape_points_on_shape_pt_sequence"

  create_table "stop_time_services", id: false, force: true do |t|
    t.integer "stop_time_id",               null: false
    t.string  "stop_id",                    null: false
    t.string  "service_id",     limit: 128, null: false
    t.integer "arrival_time"
    t.integer "departure_time"
  end

  add_index "stop_time_services", ["arrival_time"], name: "index_stop_time_services_on_arrival_time"
  add_index "stop_time_services", ["departure_time"], name: "index_stop_time_services_on_departure_time"
  add_index "stop_time_services", ["service_id"], name: "index_stop_time_services_on_service_id"
  add_index "stop_time_services", ["stop_id"], name: "index_stop_time_services_on_stop_id"
  add_index "stop_time_services", ["stop_time_id"], name: "index_stop_time_services_on_stop_time_id"

  create_table "stop_times", force: true do |t|
    t.string  "stop_id",                         null: false
    t.string  "trip_id",                         null: false
    t.integer "stop_sequence",                   null: false
    t.integer "arrival_time",                    null: false
    t.integer "departure_time",                  null: false
    t.string  "stop_headsign",       limit: 512
    t.integer "pickup_type"
    t.integer "drop_off_type"
    t.float   "shape_dist_traveled"
  end

  add_index "stop_times", ["arrival_time"], name: "index_stop_times_on_arrival_time"
  add_index "stop_times", ["departure_time"], name: "index_stop_times_on_departure_time"
  add_index "stop_times", ["stop_id"], name: "index_stop_times_on_stop_id"
  add_index "stop_times", ["trip_id"], name: "index_stop_times_on_trip_id"

  create_table "stops", force: true do |t|
    t.string  "stop_id",                          null: false
    t.string  "stop_code"
    t.string  "stop_name",           limit: 512,  null: false
    t.text    "stop_desc"
    t.float   "stop_lat",                         null: false
    t.float   "stop_lon",                         null: false
    t.string  "zone_id"
    t.string  "stop_url",            limit: 1024
    t.integer "location_type"
    t.string  "parent_station"
    t.string  "stop_timezone"
    t.integer "wheelchair_boarding"
  end

  add_index "stops", ["stop_code"], name: "index_stops_on_stop_code"
  add_index "stops", ["stop_id"], name: "index_stops_on_stop_id", unique: true
  add_index "stops", ["stop_lat"], name: "index_stops_on_stop_lat"
  add_index "stops", ["stop_lon"], name: "index_stops_on_stop_lon"

  create_table "trip_days", force: true do |t|
    t.string  "service_id", limit: 128, null: false
    t.integer "day",                    null: false
  end

  add_index "trip_days", ["day"], name: "index_trip_days_on_day"
  add_index "trip_days", ["service_id"], name: "index_trip_days_on_service_id"

  create_table "trips", force: true do |t|
    t.string  "trip_id",                        null: false
    t.string  "route_id",                       null: false
    t.string  "service_id",         limit: 128, null: false
    t.string  "trip_headsign",      limit: 512
    t.string  "trip_short_name",    limit: 512
    t.integer "direction_id"
    t.string  "block_id",                       null: false
    t.string  "shape_id",                       null: false
    t.integer "last_stop_sequence"
  end

  add_index "trips", ["last_stop_sequence"], name: "index_trips_on_last_stop_sequence"
  add_index "trips", ["route_id"], name: "index_trips_on_route_id"
  add_index "trips", ["service_id"], name: "index_trips_on_service_id"
  add_index "trips", ["shape_id"], name: "index_trips_on_shape_id"
  add_index "trips", ["trip_id"], name: "index_trips_on_trip_id", unique: true

end
