class MigrateToRrd < ActiveRecord::Migration
  def up
    Sensor.all.each(&:create_rrd)
    drop_table :sensor_readings
    # Hack to execute vacuum outside of transaction
    execute "commit"
    execute "vacuum"
    execute "begin transaction"
  end
end
