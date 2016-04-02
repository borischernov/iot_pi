#
# Network reset code
#
# If GPIO reset pin (GPIO7 by default) is shortened with ground - network configuration is being reset to defaults (see config/interfaces.default) 
#
require 'gpio'

if SETTINGS[:network_reset_gpio]
  Gpio.setup(SETTINGS[:network_reset_gpio], :in, :up)
  sleep(0.1)
  rst = Gpio.read(SETTINGS[:network_reset_gpio])
  
  if rst == '0'
    # Reset network configuration
    `cat #{APP_ROOT}/settings/interfaces.default >/etc/network/interfaces`
    `/usr/sbin/service networking restart` 
  end
end