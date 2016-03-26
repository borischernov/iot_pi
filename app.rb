require 'rubygems'
require 'bundler'

INCLUDED = caller.any? 
APP_ROOT = File.dirname(__FILE__)

unless INCLUDED
  require 'sinatra'
  require "sinatra/config_file"
  require 'sinatra/form_helpers'

  config_file File.join(APP_ROOT, 'settings/config.yml')
end

require_relative 'models/init'
require_relative 'controllers/init' unless INCLUDED




