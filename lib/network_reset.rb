#
# Network reset code
#
# If GPIO reset pin (GPIO7 by default) is shortened with ground - network configuration is being reset to defaults (see config/interfaces.default) 
#

if SETTINGS[:network_reset_gpio]
  `echo #{SETTINGS[:network_reset_gpio]} >/sys/class/gpio/export`
  sleep(0.1)
  `echo in >/sys/class/gpio/gpio#{SETTINGS[:network_reset_gpio]}/direction`
  sleep(0.1)
  rst = File.read("/sys/class/gpio/gpio#{SETTINGS[:network_reset_gpio]}/value").to_s.strip rescue nil
  
  if rst == '0'
    # Reset network configuration
    `cat #{APP_ROOT}/settings/interfaces.default >/etc/network/interfaces`
    `/usr/sbin/service networking restart` 
  end
end