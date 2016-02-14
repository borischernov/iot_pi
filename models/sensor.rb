class Sensor < ActiveRecord::Base
  has_many :sensor_readings, dependent: :destroy

  enum  sensor_type: [ "Temperature" ]
  enum  ext_service: ["None", "EasyIoT Cloud", "Thingspeak"]

  validates :ident, presence: true, uniqueness: true
  validates :ext_service_ident, presence: { :if => :has_ext_service? }

  def to_s
    self.name || self.ident
  end

  def last_reading
    self.sensor_readings.order('timestamp desc').first
  end

  def last_value
    r = last_reading
    r ? r.value : nil
  end

  def last_formatted_value
    v = self.last_value
    return '-' if v.nil?
    case self.sensor_type
      when 'Temperature'
        "%.1f &deg;C" % v
      else
        v.to_s
    end
  end
  
  def has_ext_service?
    self.ext_service.to_s != "None"
  end
end