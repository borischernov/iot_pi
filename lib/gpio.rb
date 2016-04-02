#
# GPIO manipulation via sysfs interface
#
module Gpio
  def self.setup(pin, direction, pull = :up)
    self.write_file('export', pin)
    sleep(0.1)
    self.write_file("gpio#{pin}/direction", direction)
    self.write_file("gpio#{pin}/pull", pull) if direction.to_s == 'in'
  end
  
  def self.write(pin, value)
    self.write_file("gpio#{pin}/value", value)
  end
  
  def self.read(pin)
    self.read_file("gpio#{pin}/value")
  end
  
  protected
  
  def self.write_file(path, content)
    File.open("/sys/class/gpio/#{path}", 'w') { |f| f.write content } rescue nil
  end
  
  def self.read_file(path)
    c = File.read("/sys/class/gpio/#{path}") rescue nil
    c.nil? ? nil : c.to_i 
  end
end