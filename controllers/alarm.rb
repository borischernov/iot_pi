get '/alarms' do
  @alarms = Alarm.all
  erb :'alarm/index'
end

get '/alarm/new' do
  @alarm = Alarm.new(enabled: true)
  erb :'alarm/new'
end

post '/alarm/create' do
  @alarm = Alarm.create(params[:alarm])
  return redirect to('/alarms') if @alarm.id
  erb :'alarm/new'
end

get '/alarm/edit/:id' do
  @alarm = Alarm.find(params[:id])
  erb :'alarm/edit'
end

post '/alarm/update/:id' do
  @alarm = Alarm.find(params[:id])
  ok = @alarm.update_attributes(params[:alarm])
  return redirect to('/alarms') if ok 
  erb :'alarm/edit'
end

post '/alarm/delete/:id' do
  Alarm.find(params[:id]).destroy
  redirect to('/alarms')
end
