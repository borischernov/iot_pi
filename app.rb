require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require_relative 'models/init'

get '/' do
  @sensors = Sensor.all
  erb :index
end

