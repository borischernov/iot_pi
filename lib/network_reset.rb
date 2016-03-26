#
# Network reset code
#
# If GPIO7 is shortened with ground - network configuration is being reset to defaults (see config/interfaces.default) 
#

`echo 7 >/sys/class/gpio/export`
sleep(0.1)
`echo in >/sys/class/gpio/gpio7/direction`
sleep(0.1)
rst = File.read("/sys/class/gpio/gpio7/value").to_s.strip rescue nil

if rst == '0'
  # Reset network configuration
  `cat #{APP_ROOT}/settings/interfaces.default >/etc/network/interfaces`
  `/usr/sbin/service networking restart` 
end
