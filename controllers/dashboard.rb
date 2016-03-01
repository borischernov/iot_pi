get '/' do
  @sensors = Sensor.all.order(:name)
  erb :'dashboard/index'
end

get '/screen' do
  @sensors = Sensor.all.order(:name)
  
  `/sbin/ifconfig eth0` =~ /inet\ addr\:(.*?)\ /
  @ip = $1.to_s.strip
  `/sbin/ifconfig wlan0` =~ /inet\ addr\:(.*?)\ /
  @ip += " " + $1.to_s.strip
   
  erb :'dashboard/screen'
end
