require File.join(APP_ROOT,'/lib/ext_services')

class SensorReading < ActiveRecord::Base
  belongs_to :sensor

  validates :sensor, presence: true  
  validates :value, presence: true, numericality: true
  validates :timestamp, presence: true

  after_create :send_data
  
  def send_data
    ext_svc = {"EasyIoT Cloud" => EasyIotCloud, "Thingspeak" => Thingspeak}[self.sensor.ext_service]
    ext_svc.send_data(self.sensor.ext_service_ident, value.to_s) if ext_svc 
  end

end
