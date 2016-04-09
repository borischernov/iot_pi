class CreateAlarms < ActiveRecord::Migration
  def change
    create_table :alarms, force: :cascade do |t|
      t.string :description
      t.boolean :enabled
      t.boolean :active, default: false
      t.references :sensor
      t.integer :operation
      t.float :value
      t.integer :activate_action
      t.references :activate_actuator
      t.text :activate_params
      t.integer :restore_action
      t.references :restore_actuator
      t.text :restore_params
      t.datetime :activated_at
      t.datetime :created_at,        null: false
      t.datetime :updated_at,        null: false
    end
  
    add_index :alarms, :sensor_id
    add_index :alarms, :activate_actuator_id
    add_index :alarms, :restore_actuator_id
    add_index :alarms, :operation
  end
end
