get '/sensor/edit/:id' do
  @sensor = Sensor.find(params[:id])
  erb :'sensor/edit'
end

post '/sensor/edit/:id' do
  @sensor = Sensor.find(params[:id])
  ok = @sensor.update_attributes(params[:sensor])
  return redirect to('/') if ok
  erb :'sensor/edit'
end

post '/sensor/delete/:id' do
  Sensor.find(params[:id]).destroy
  redirect to('/')
end
