get '/' do
  @sensors = Sensor.all
  erb :index
end
