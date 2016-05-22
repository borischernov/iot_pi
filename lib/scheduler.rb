#
# Scheduled tasks
#

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

if SETTINGS[:local_sensors] && SETTINGS[:local_sensors][:poll_interval] 
  require_relative 'local_sensors'
  
  scheduler.every SETTINGS[:local_sensors][:poll_interval], overlap: false do
    LocalSensors.poll_local_sensors  
  end
end

if SETTINGS[:local_console]
  require_relative 'local_console'
  
  scheduler.every SETTINGS[:local_console], overlap: false do
    LocalConsole.show_info
  end
end

scheduler.every '1m', overlap: false do
  Alarm.detect_sensor_failures
end
