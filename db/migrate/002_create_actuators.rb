class CreateActuators < ActiveRecord::Migration
  def change
    create_table "actuators", force: :cascade do |t|
      t.string   "ident"
      t.string   "name"
      t.integer  "actuator_type"
      t.datetime "last_seen_at"
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
      t.string   "address"
      t.string   "value_requested"
      t.string   "value_set"
      t.string   "secret"
      t.boolean  "active_low"
    end
  
    add_index "actuators", ["ident"], name: "index_actuators_on_ident"
    add_index "actuators", ["value_requested","value_set"], name: "index_actuators_on_values"
  end
end
