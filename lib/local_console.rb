#
# Show info on local console
#
require 'ansi'

module LocalConsole
  def self.show_info
    puts ANSI.clear_screen
    puts ANSI.move(0,0)
    puts self.status
    puts self.sensors
  end
  
  private
  
  def self.status
    ips = `/sbin/ip addr`.scan(/inet (\d+\.\d+\.\d+.\d+)\//).flatten.reject { |a| a == '127.0.0.1'}.join(" ")
    " " + ANSI.white + ips + "\t\t" + Time.now.to_s + "\n\n"
  end
  
  def self.sensors
    Sensor.all.order(:name).map do |sensor|
      " " +
      (sensor.alive? ? ANSI.green : ANSI.red) +
      "#{sensor.to_s} : #{sensor.last_formatted_value.to_s.gsub('&deg;',"\xC2\xB0")}"
    end.join("\n")
  end
end