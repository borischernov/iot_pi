#
# Polling local sensors
#
require 'i2c/i2c'
require_relative 'ads1015'

module LocalSensors
  def self.poll_local_sensors
    self.poll_1wire_sensors if SETTINGS[:local_sensors][:poll_1wire]
    self.poll_i2c_sensors if SETTINGS[:local_sensors][:poll_i2c]
  end
  
  protected 
  
  def self.poll_1wire_sensors
    self.check_1wire_modules
    
    # Scan for DS18B20 temperature sensors
    `ls -1 /sys/bus/w1/devices`.scan(/28\-[0-9a-f]{12}/).each do |sensor_id|
      data = File.read("/sys/bus/w1/devices/#{sensor_id}/w1_slave") rescue ""
      next unless data.include?("YES") && data =~ /t=(-?\d+)/
      temp = $1.to_f / 1000
      
      Sensor.create_reading(sensor_id, temp, Time.now, 'Temperature')
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
  
  def self.poll_i2c_sensors
    self.poll_am2320
    self.poll_ads1015
  end

  def self.poll_am2320
    begin
      # Check for AM2320 sensor
      addr = 0x5C  # AM2320 i2c address
      bus = ::I2C.create("/dev/i2c-#{SETTINGS[:poll_i2c]}")
      
      bus.write(addr) rescue nil        # first write is just to wake the sensor up, it isn't ack'ed and raises an exception
      sleep(0.001)                      # wait the sensor to wake up
      data = bus.read(addr, 8, 3, 0, 4) # Write [3,0,4] and then read 8 bytes
      # Byte 0: Should be Modbus function code 0x03
      # Byte 1: Should be number of registers to read (0x04)
      # Byte 2: Humidity high 8 bits
      # Byte 3: Humidity low 8 bits
      # Byte 4: Temperature high 8 bits
      # Byte 5: Temperature low 8 bits
      # Byte 6: CRC high byte
      # Byte 7: CRC low byte

      data = data.unpack("C*")
      return unless data.length == 8 && data[0] == 3 && data[1] == 4
      
      humidity = (data[2] << 8 | data[3]).to_f / 10
      
      temperature = data[4] << 8 | data[5]
      temperature = -(temperature & 0x7FFF) if (data[4] & 0x80) != 0
      temperature = temperature.to_f / 10
      
      Sensor.create_reading("am2320-local-t", temperature, Time.now, 'Temperature')
      Sensor.create_reading("am2320-local-rh", humidity, Time.now, 'Relative Humidity')
    rescue
    end    
  end
  
  def self.poll_ads1015
    begin
      bus = I2C.create("/dev/i2c-#{SETTINGS[:poll_i2c]}")
      adc = ADS1015.new(bus, 0x48)
      adc.configure(CFG_MUX_AIN0 | CFG_PGA_4_096 | CFG_MODE_CONT | CFG_DR_128 | CFG_COMP_TRAD | CFG_CMP_DISABLE)
      4.times do |chan|
        d = adc.read_channel(chan)
        v = d.to_f * 4.096 / 0x8000

        Sensor.create_reading("ads1015-#{chan}-local-v", v, Time.now, 'Voltage')
      end
    rescue
    end    
  end
  
end
