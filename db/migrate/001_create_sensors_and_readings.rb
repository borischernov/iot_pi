class CreateSensorsAndReadings < ActiveRecord::Migration
  def change
    create_table "sensor_readings", force: :cascade do |t|
      t.integer  "sensor_id"
      t.float    "value"
      t.datetime "timestamp"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  
    add_index "sensor_readings", ["sensor_id", "timestamp"], name: "index_sensor_readings_on_sensor_id_and_timestamp"
  
    create_table "sensors", force: :cascade do |t|
      t.string   "ident"
      t.string   "name"
      t.integer  "sensor_type"
      t.datetime "last_seen_at"
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
      t.string   "address"
      t.integer  "ext_service"
      t.string   "ext_service_ident"
    end
  
    add_index "sensors", ["ident"], name: "index_sensors_on_ident"
  end
end
