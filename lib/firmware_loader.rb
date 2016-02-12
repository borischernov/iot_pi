module FirmwareLoader
  PIN_RESET = 0
  PIN_GPIO0 = 1
  APP_ROOT = File.join(File.dirname(__FILE__), '..') 
  
  def self.flash_nodemcu
    # enter bootloader
    self.status("Entering bootloader mode")
    self.setup_gpio(PIN_RESET, :out)    
    self.setup_gpio(PIN_GPIO0, :out)
    self.gpio_out(PIN_GPIO0, 0)
    self.gpio_out(PIN_RESET, 0)
    sleep(0.1)
    self.gpio_out(PIN_RESET, 1)
    
    # check MAC
    self.status("Checking connectivity")
    unless self.esptool("read_mac").include?("MAC:")
      self.status("Failed to connect to ESP8266")
      return false
    end    
    
    # flash NodeMCU
    self.status("Flashing NodeMCU")
    fw_file = File.join(APP_ROOT, '/firmware/nodemcu/nodemcu.bin')
    unless self.esptool("write_flash 0x00000 #{fw_file}").include?("Wrote")
      self.status("Failed to flash NodeMCU")
      return false
    end
    
    # resetting in normal mode
    self.gpio_out(PIN_GPIO0, 1)
    self.gpio_out(PIN_RESET, 0)
    sleep(0.1)
    self.gpio_out(PIN_RESET, 1)

    self.status("Done flashing firmware")

    true
  end
  
  private
  
  def self.status(str)
    puts str
  end
  
  def self.setup_gpio(num, dir)
    num = num.to_i
    File.open("/sys/class/gpio/export", 'w') { |f| f.puts num }
    File.open("/sys/class/gpio/gpio#{num}/direction", 'w') { |f| f.puts dir.to_s }
  end

  def self.gpio_out(num, val)
    File.open("/sys/class/gpio/gpio#{num}/value", 'w') { |f| f.puts val.to_i }
  end
  
  def self.esptool(args)
    esptool = File.join(APP_ROOT, '/bin/esptool.py')
    `#{esptool} --port /dev/ttyAMA0 #{args}`
  end
end