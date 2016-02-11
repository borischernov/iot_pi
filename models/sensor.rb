class Sensor < ActiveRecord::Base
  has_many :sensor_readings, dependent: :destroy

  enum  sensor_type: [ "Temperature" ]

  validates :ident, presence: true, uniqueness: true

  def to_s
    self.name || self.ident
  end

  def last_value
    r = self.sensor_readings.order('timestamp desc').first
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
end