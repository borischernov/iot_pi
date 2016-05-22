class MigrateToRrd < ActiveRecord::Migration
  def up
    Sensor.all.each(&:create_rrd)
    drop_table :sensor_readings
    ActiveRecord::Base.connection.execute("vacuum")
  end
end
