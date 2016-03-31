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
  r = Sensor.create_reading(sensor, value, ts ? Time.at(ts) : Time.now) 
  r.id ? "OK" : "ERROR"
end