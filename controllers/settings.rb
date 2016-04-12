get '/settings' do
  @settings = SETTINGS
  @all_settings = all_settings
  erb :'settings/index'
end

post '/settings' do
  settings = settings_from_params(all_settings, params[:settings])
  SETTINGS = ActiveSupport::HashWithIndifferentAccess.new(settings)
  File.open(File.join(APP_ROOT, 'settings', 'settings.yml'), 'w') { |f| f.write settings.to_yaml }
  redirect to('/')
end

def settings_from_params(all, params)
  s = {}
  params ||= {}
  all.each do |setting|
    s[setting[:name].to_s] = case setting[:type]
      when :group
        settings_from_params(setting[:settings], params[setting[:name]])
      when :string
        params[setting[:name]].to_s.strip == "" ? nil : params[setting[:name]].to_s.strip
      when :integer
        params[setting[:name]].to_s.strip == "" ? nil : params[setting[:name]].to_i
    end
  end
  s
end

def all_settings
  [
    {name: :local_console, title: 'Refresh interval for local console (empty to disable)', type: :string},
    {name: :readings_retention_days, title: 'Retention interval for sensor readings, days', type: :integer},
    {name: :network_reset_gpio, title: 'GPIO Pin for Network Settings Reset Switch', type: :integer},
    {name: :esp8266, title: 'ESP8266 connection settings', type: :group, settings: [
      {name: :serial_port, title: 'Serial Port', type: :string },
      {name: :serial_speed, title: 'Baudrate', type: :integer },
      {name: :pin_reset, title: 'GPIO for ESP8266 Reset pin', type: :integer},
      {name: :pin_gpio0, title: 'GPIO for ESP8266 GPIO0 pin', type: :integer},    
    ]},
    {name: :local_sensors, title: 'Local Sensors', type: :group, settings: [
      {name: :poll_interval, title: 'Poll Interval', type: :string },
    ]},
    {name: :local_actuators, title: 'Local Actuators', type: :group, settings: [
      {name: :gpio_out, title: 'GPIO Out Pins (comma separated)', type: :string },
    ]},
    {name: :gsm_modem, title: 'GSM Modem', type: :group, settings: [
      {name: :port, title: 'Serial Port', type: :string },
      {name: :baudrate, title: 'Baudrate', type: :integer, default: 115200 },
      {name: :pin, title: 'SIM PIN', type: :string},
    ]},
  ]
end
