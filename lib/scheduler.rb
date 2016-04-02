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

if SETTINGS[:readings_retention_days].to_i > 0
  scheduler.every '1h', overlap: false do
    SensorReading.where('timestamp < ?', SETTINGS[:readings_retention_days].to_i.days.ago).delete_all
  end
end

if SETTINGS[:local_console]
  require_relative 'local_console'
  
  scheduler.every SETTINGS[:local_console], overlap: false do
    LocalConsole.show_info
  end
end