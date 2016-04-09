class Sensor < ActiveRecord::Base
  has_many :sensor_readings, dependent: :delete_all
  has_many :alarms, dependent: :destroy

  enum  sensor_type: [ "Temperature", "Relative Humidity" ]
  enum  ext_service: ["None", "EasyIoT Cloud", "Thingspeak"]

  validates :ident, presence: true, uniqueness: true
  validates :ext_service_ident, presence: { :if => :has_ext_service? }

  after_update do
    self.alarms.enabled.each(&:check) if self.last_value_changed?
  end

  def to_s
    self.name || self.ident
  end

  def alive?
    self.last_seen_at && self.last_seen_at > 10.minutes.ago
  end

  def last_formatted_value
    v = self.last_value
    return '-' if v.nil?
    case self.sensor_type
      when 'Temperature'
        "%.1f &deg;C" % v
      when 'Relative Humidity'
        "%.1f %" % v
      else
        v.to_s
    end
  end
  
  def has_ext_service?
      self.ext_service && self.ext_service.to_s != "None"
  end
  
  def self.create_reading(ident, value, tstamp = Time.now, sensor_type = nil, address = nil)
    sensor_type ||= ident =~ /\-rh$/ ? 'Relative Humidity' : 'Temperature'

    sensor = Sensor.where(ident: ident).first_or_create do |s|
      s.sensor_type = sensor_type
    end
    
    sensor.update_attributes(last_seen_at: Time.now, address: address, last_value: value)
    sensor.sensor_readings.create(value: value, timestamp: tstamp)
  end
end