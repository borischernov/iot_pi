class SensorReading < ActiveRecord::Base
  belongs_to :sensor

  validates :sensor, presence: true  
  validates :value, presence: true, numericality: true
  validates :timestamp, presence: true

end
