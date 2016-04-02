#
# Controlling local actuators
#
require 'gpio'

module LocalActuators
  def self.setup_actuators
    SETTINGS[:local_actuators][:gpio_out].to_s.split(",").map { |g|  self.setup_gpio_out(g.to_i) } if SETTINGS[:local_actuators][:gpio_out]
  end

  def self.set_actuator(actuator)
    ok = case actuator.ident
    when /local-gpio-(.*?)-dout/
      gpio = $1.to_i
      value = actuator.value_requested.to_i == 0 ? 0 : 1
      value = 1 - value if actuator.active_low
      Gpio.write(gpio, value)
    else
      false
    end
    actuator.update_attribute(:value_set, actuator.value_requested) if ok && actuator.value_set != actuator.value_requested
    ok 
  end

  protected
  
  def self.setup_gpio_out(gpio)
    actuator = Actuator.where(ident: "local-gpio-#{gpio}-dout").first_or_create do |a|
      a.actuator_type = "Switch"
      a.active_low = true
      a.value_requested = '0'
      a.value_set = '0'
      a.address = 'local'
    end
    Gpio.setup(gpio, :out)    
    self.set_actuator(actuator)
  end
  
end