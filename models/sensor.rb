require "rrd"
class Sensor < ActiveRecord::Base
  has_many :alarms, dependent: :destroy

  enum  sensor_type: [ "Temperature", "Relative Humidity", "Voltage"]
  enum  ext_service: ["None", "EasyIoT Cloud", "Thingspeak"]

  validates :ident, presence: true, uniqueness: true
  validates :ext_service_ident, presence: { :if => :has_ext_service? }

  after_update do
    self.alarms.enabled.each(&:check) rescue nil if self.last_value_changed? 
  end

  after_create :create_rrd
  after_destroy :delete_rrd

  def to_s
    self.name.to_s.strip == "" ? self.ident : self.name
  end

  def alive?
    self.last_seen_at && self.last_seen_at > (SETTINGS[:sensor_alive_threshold] || 10).minutes.ago
  end

  def last_formatted_value
    v = self.last_value
    return '-' if v.nil?
    case self.sensor_type
      when 'Temperature'
        "%.1f &deg;C" % v
      when 'Relative Humidity'
        "%.1f %" % v
      when 'Voltage'
        "%.1f V" % v
      else
        v.to_s
    end
  end
  
  def has_ext_service?
      self.ext_service && self.ext_service.to_s != "None"
  end
  
  def readings_rrd_path
    File.join(APP_ROOT, 'db', 'rrd', "sensor_#{self.id}.rrd")
  end
  
  def create_rrd
    rrd = RRD::Base.new(self.readings_rrd_path)
    rrd.create! :start => Time.now, :step => 1.minutes do
      datasource "readings", :type => :gauge, :heartbeat => 2.minutes
      archive :average, :every => 1.minutes, :during => SETTINGS[:readings_retention_days].days
    end
  end
  
  def delete_rrd
    path = self.readings_rrd_path
    FileUtils.rm_f(path) if File.exists?(path)
  end
  
  def rrd_add_reading(time, value)
    rrd = RRD::Base.new(self.readings_rrd_path)
    rrd.update!(time, value)
  end
  
  EXPORTED_ATTRS = [:ident, :name, :sensor_type, :ext_service, :ext_service_ident] 
  def to_hash
    self.attributes.select { |k,v| EXPORTED_ATTRS.include?(k) }
  end
  
  def self.from_hash(h)
    ident = h.delete(:ident)
    record = self.where(ident: ident).first || self.new(ident: ident)
    record.update_attributes(h)
  end
  
  def self.guess_type(ident)
    return 'Relative Humidity' if ident =~ /\-rh$/
    return 'Voltage' if ident =~ /\-v$/
    'Temperature'
  end
  
  def self.create_reading(ident, value, tstamp = Time.now, sensor_type = nil, address = nil)
    sensor_type ||= self.guess_type(ident)

    sensor = Sensor.where(ident: ident).first_or_create do |s|
      s.sensor_type = sensor_type
    end

    value = value * sensor.factor + sensor.offset
    
    sensor.update_attributes(last_seen_at: Time.now, address: address, last_value: value)
    sensor.rrd_add_reading(tstamp, value)
  end
end