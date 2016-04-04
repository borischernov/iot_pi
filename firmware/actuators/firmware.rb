{
  name: "Misc actuators",
  files: ['init.lua'],
  params: [
    {name: 'actuator_type', title: 'Actuator Type', type: :select, options: [
      ['gpio', 'Dual channel GPIO, active low'],
    ]},
  ],
  check: "Setting up WIFI..."
}
