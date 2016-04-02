get '/' do
  @sensors = Sensor.all.order(:name)
  @actuators = Actuator.all.order(:name)
  erb :'dashboard/index'
end
