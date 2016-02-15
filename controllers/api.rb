 post '/api/set_data/:sensor/:value' do
   set_data
 end
  
 get '/api/set_data/:sensor/:value' do
   set_data
 end

def set_data
  sensor = Sensor.where(ident: params[:sensor]).first_or_create do |s|
    s.sensor_type = "Temperature"
  end
  sensor.update_attributes(last_seen_at: Time.now, address: request.ip)
  sensor.sensor_readings.create(value: params[:value], timestamp: params[:ts] ? Time.at(params[:ts]) : Time.now)
  "OK"
end