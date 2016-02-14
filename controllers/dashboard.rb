get '/' do
  @sensors = Sensor.all
  erb :'dashboard/index'
end

get '/screen' do
  @sensors = Sensor.all
  
  `/sbin/ifconfig eth0` =~ /inet\ addr\:(.*?)\ /
  @ip = $1.to_s.strip
   
  erb :'dashboard/screen'
end
