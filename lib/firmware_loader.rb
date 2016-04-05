#
# Class for programming ESP8266
#

begin 
  require 'wiringpi'
rescue LoadError
end

require 'gpio'

class FirmwareLoader
  def initialize(logger = nil)
    @pin_reset = SETTINGS[:esp8266][:pin_reset]
    @pin_gpio0 = SETTINGS[:esp8266][:pin_gpio0]
    @port = SETTINGS[:esp8266][:serial_port]
    @speed = SETTINGS[:esp8266][:serial_speed]
    
    Gpio.setup(@pin_reset, :out)
    Gpio.setup(@pin_gpio0, :out)

    @logger = logger 
  end
  
  def flash_nodemcu(just_check = false)
    # enter bootloader
    status("Entering bootloader mode")
    reset_esp(0)
    
    # check MAC
    status("Checking connectivity")
    unless esptool("read_mac").include?("MAC:")
      status("Failed to connect to ESP8266")
      return false
    end    
    
    unless just_check
      # flash NodeMCU
      status("Flashing NodeMCU")
      fw_file = File.join(APP_ROOT, '/firmware/nodemcu/nodemcu.bin')
      unless esptool("write_flash 0x00000 #{fw_file}").include?("Wrote")
        status("Failed to flash NodeMCU")
        return false
      end
    end
    
    # resetting in normal mode
    reset_esp(1)

    status("Done flashing NodeMCU")

    true
  end
  
  def send_file(file_name, file_data)
    @s = WiringPi::Serial.new(@port, @speed)
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
    status("Uploading scripts ...")

    reset_esp(1)
    sleep(3)

    @params = params
    b = binding
    files.each do |file|
      path = File.join(fw_dir, "#{file}.erb")
      erb = ERB.new(File.read(path))
      result = erb.result(b)
      send_file(file, result)
    end

    reset_esp(1)
  end
  
  private
  
  def serial_line(line)
    serial_read(false)
    @s.serial_puts("#{line}\n")
    status(serial_read)
  end
  
  def serial_read(line = true)
    str = ""
    loop do
      c = @s.serial_get_char
      break if c <= 0
      chr = c.chr
      break if chr == (line ? "\n" : ">")
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
    Gpio.write(@pin_gpio0, gpio0)
    Gpio.write(@pin_reset, 0)
    sleep(0.1)
    Gpio.write(@pin_reset, 1)
  end
  
  def esptool(args)
    esptool = File.join(APP_ROOT, '/bin/esptool.py')
    out = ""
    IO.popen("#{esptool} --port #{@port} #{args}") do |io|
      loop do 
        line = io.gets rescue nil
        break unless line
        out += line
        status(line.strip)
      end 
    end
    out
  end
end