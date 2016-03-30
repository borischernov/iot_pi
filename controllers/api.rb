 post '/api/set_data/:sensor/:value' do
   set_data(params[:sensor], params[:value], params[:ts])
 end
  
 get '/api/set_data/:sensor/:value' do
   set_data(params[:sensor], params[:value], params[:ts])
 end

 post '/api/set_data_multiple/:data' do
   set_data_multiple(params[:data], params[:ts])
 end

 get '/api/set_data_multiple/:data' do
   set_data_multiple(params[:data], params[:ts])
 end

def set_data_multiple(data, ts = nil)
  data.to_s.split("|").each_slice(2).map do |sensor, value|
    set_data(sensor, value, ts)
  end.join("|")
end

def set_data(sensor, value, ts = nil)
  sensor = Sensor.where(ident: sensor).first_or_create do |s|
    s.sensor_type = sensor =~ /\-rh$/ ? 'Relative Humidity' : 'Temperature'
  end
  sensor.update_attributes(last_seen_at: Time.now, address: request.ip)
  sensor.sensor_readings.create(value: value, timestamp: ts ? Time.at(ts) : Time.now)
  "OK"
end