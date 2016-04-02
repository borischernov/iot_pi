get '/actuator/edit/:id' do
  @actuator = Actuator.find(params[:id])
  erb :'actuator/edit'
end

post '/actuator/edit/:id' do
  @actuator = Actuator.find(params[:id])
  ok = @actuator.update_attributes(params[:actuator])
  return redirect to('/') if ok
  erb :'actuator/edit'
end

post '/actuator/delete/:id' do
  Actuator.find(params[:id]).destroy
  redirect to('/')
end

get '/actuator/set/:id/:value' do
  Actuator.find(params[:id]).value = params[:value]
  redirect to('/')
end
