{
  name: "Misc sensors",
  files: ['ds18b20.lua', 'init.lua'],
  params: [
    {name: 'sensor_type', title: 'Sensor Type', type: :select, options: [
      ['ds18b20', 'DS18B20 Temperature'],
      ['am2320', 'AM2320 Temperature / Relative Humidity']] },
    {name: 'deep_sleep', title: 'Use Deep Sleep', type: :checkbox},
    {name: 'poll_interval', title: 'Poll interval, sec.', type: :string, value: 60},
  ],
  check: "Setting up WIFI..."
}
