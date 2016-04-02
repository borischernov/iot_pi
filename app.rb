require 'rubygems'
require 'bundler'

INCLUDED = caller.any? 
APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(APP_ROOT,'lib'))

unless INCLUDED
  require 'sinatra'
  require "sinatra/config_file"
  require 'sinatra/form_helpers'

  config_file File.join(APP_ROOT, 'settings', 'config.yml')
end

require_relative 'models/init'

SETTINGS = ActiveSupport::HashWithIndifferentAccess.new(YAML.load(File.read(File.join(APP_ROOT, 'settings', 'settings.yml')))) rescue {}

unless INCLUDED
  require_relative 'lib/network_reset'

  require_relative 'controllers/init' 

  if SETTINGS[:local_actuators]
    require_relative 'lib/local_actuators'
    LocalActuators.setup_actuators
  end

  require_relative 'lib/scheduler'
end



