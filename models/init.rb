require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  File.join(File.dirname(__FILE__),'../db','db.sqlite3')
)

after do
  ActiveRecord::Base.connection.close
end

require_relative 'sensor'
require_relative 'sensor_reading'
