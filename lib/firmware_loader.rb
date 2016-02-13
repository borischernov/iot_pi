require 'wiringpi'

class FirmwareLoader
  PIN_RESET = 0
  PIN_GPIO0 = 1
  APP_ROOT = File.join(File.dirname(__FILE__), '..') 
  
  def initialize(logger = nil)
    @io = WiringPi::GPIO.new do |gpio|
      gpio.pin_mode(PIN_RESET, WiringPi::OUTPUT)
      gpio.pin_mode(PIN_GPIO0, WiringPi::OUTPUT)
    end

    @logger = logger 
  end
  
  def flash_nodemcu
    # enter bootloader
    status("Entering bootloader mode")
    reset_esp(WiringPi::LOW)
    
    # check MAC
    status("Checking connectivity")
    unless self.esptool("read_mac").include?("MAC:")
      status("Failed to connect to ESP8266")
      return false
    end    
    
    # flash NodeMCU
    status("Flashing NodeMCU")
    fw_file = File.join(APP_ROOT, '/firmware/nodemcu/nodemcu.bin')
    unless self.esptool("write_flash 0x00000 #{fw_file}").include?("Wrote")
      status("Failed to flash NodeMCU")
      return false
    end
    
    # resetting in normal mode
    reset_esp(WiringPi::HIGH)

    status("Done flashing firmware")

    true
  end
  
  def send_file(file_name, file_data)
    @s = WiringPi::Serial.new('/dev/ttyAMA0', 9600)
    serial_line("file.remove(\"#{file_name}\");")
    serial_line("file.open(\"#{file_name}\",\"w+\");")
    serial_line("w = file.writeline;")
    file_data.each_line do |line|
      serial_line("w([[#{line.chomp}]]);")
    end
    serial_line("file.close();")
    @s.serial_close
  end
  
  def send_firmware(fw_dir, files, params)
    reset_esp(WiringPi::HIGH)

    @params = params
    files.each do |file|
      path = File.join(fw_dir, "#{file}.erb")
      erb = ERB.new(File.read(path))
      result = erb.result
      send_file(file, result)
    end

    reset_esp(WiringPi::HIGH)
  end
  
  private
  
  def serial_line(line)
    @s.serial_puts("#{line}\n")
    status(serial_read)
  end
  
  def serial_read
    str = ""
    loop do
      chr = @s.serial_get_char.chr
      break if chr == "\n"
      str += chr
    end
    str
  end
  
  def status(str)
    if @logger
      @logger.call(str)
    else
      puts str      
    end
  end
  
  def reset_esp(gpio0)
    @io.digital_write(PIN_GPIO0, gpio0)
    @io.digital_write(PIN_RESET, WiringPi::LOW)
    sleep(0.1)
    @io.digital_write(PIN_RESET, WiringPi::HIGH)
  end
  
  def esptool(args)
    esptool = File.join(APP_ROOT, '/bin/esptool.py')
    `#{esptool} --port /dev/ttyAMA0 #{args}`
  end
end