#/usr/bin/ruby

require './app'

module LocalSensors
  def self.poll_local_sensors
    self.poll_1wire_sensors
  end
  
  protected 
  
  def self.poll_1wire_sensors
    self.check_1wire_modules
    
    # Scan for DS18B20 temperature sensors
    `ls -1 /sys/bus/w1/devices`.scan(/28\-[0-9a-f]{12}/).each do |sensor_id|
      data = File.read("/sys/bus/w1/devices/#{sensor_id}/w1_slave") rescue ""
      next unless data.include?("YES") && data =~ /t=(-?\d+)/
      temp = $1.to_f / 1000
      
      sensor = Sensor.where(ident: sensor_id).first_or_create  do |s|
        s.sensor_type = "Temperature"
      end
      
      sensor.update_attributes(last_seen_at: Time.now, address: nil)
      sensor.sensor_readings.create(value: temp, timestamp: Time.now)
    end
  end
  
  def self.check_1wire_modules
    lsmod = `lsmod`
    unless lsmod.include?("w1_therm") && lsmod.include?("w1_gpio")
      `modprobe w1-gpio`
      `modprobe w1-therm`
      sleep(0.1)
    end
  end
end

lock = "/tmp/sensors_lock"
begin
  raise if File.exists?(lock)
  FileUtils.touch(lock)
  
  LocalSensors.poll_local_sensors

ensure
  FileUtils.rm_f(lock)
end
