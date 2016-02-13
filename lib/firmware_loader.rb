require 'wiringpi'

class FirmwareLoader
  PIN_RESET = 0
  PIN_GPIO0 = 1
  
  def initialize(logger = nil)
    `echo #{PIN_RESET} >/sys/class/gpio/export`
    `echo #{PIN_GPIO0} >/sys/class/gpio/export`
    `echo out >/sys/class/gpio/gpio#{PIN_RESET}/direction`
    `echo out >/sys/class/gpio/gpio#{PIN_GPIO0}/direction`

    @logger = logger 
  end
  
  def flash_nodemcu
    # enter bootloader
    status("Entering bootloader mode")
    reset_esp(0)
    
    # check MAC
    status("Checking connectivity")
    unless esptool("read_mac").include?("MAC:")
      status("Failed to connect to ESP8266")
      return false
    end    
    
    # flash NodeMCU
    status("Flashing NodeMCU")
    fw_file = File.join(APP_ROOT, '/firmware/nodemcu/nodemcu.bin')
    unless esptool("write_flash 0x00000 #{fw_file}").include?("Wrote")
      status("Failed to flash NodeMCU")
      return false
    end
    
    # resetting in normal mode
    reset_esp(1)

    status("Done flashing NodeMCU")

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
    status("Uploading scripts ...")

    reset_esp(1)
    sleep(5)

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
   `echo #{gpio0} >/sys/class/gpio/gpio#{PIN_GPIO0}/value`
   `echo 0 >/sys/class/gpio/gpio#{PIN_RESET}/value`
    sleep(0.1)
   `echo 1 >/sys/class/gpio/gpio#{PIN_RESET}/value`
  end
  
  def esptool(args)
    esptool = File.join(APP_ROOT, '/bin/esptool.py')
    out = ""
    IO.popen("#{esptool} --port /dev/ttyAMA0 #{args}") do |io|
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