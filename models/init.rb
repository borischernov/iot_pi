require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  File.join(File.dirname(__FILE__),'../db','db.sqlite3'),
  :timeout => 5000
)

begin
  after do
    ActiveRecord::Base.connection.close
  end
rescue
end

require_relative 'sensor'
require_relative 'actuator'
require_relative 'alarm'
