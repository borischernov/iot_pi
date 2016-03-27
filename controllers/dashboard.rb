get '/' do
  @sensors = Sensor.all.order(:name)
  erb :'dashboard/index'
end
