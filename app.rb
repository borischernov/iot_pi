require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require "sinatra/config_file"
require 'sinatra/form_helpers'

APP_ROOT = File.dirname(__FILE__)

config_file File.join(APP_ROOT, 'settings/config.yml')

require_relative 'models/init'
require_relative 'controllers/init'




