class CacheLastValue < ActiveRecord::Migration
  def change
    add_column :sensors, :last_value, :float
    Sensor.reset_column_information
    Sensor.all.each do |s|
      r = s.sensor_readings.order('timestamp desc').first rescue nil
      s.update_attribute(:last_value, r.value) if r
    end
  end
end
