class Alarm < ActiveRecord::Base
  belongs_to :sensor

  enum  operation: [ "more than", "less than", "equals", "sensor failure"]

  validates :sensor, presence: true
  validates :value, presence: {:if => :value_required?}

  after_update :check

  scope :enabled, -> { where('alarms.enabled') }
  scope :failure_checks, -> { where(operation: 3) }

  ACTIONS = ["Set Actuator"]

  [:activate, :restore].each do |action|
    belongs_to :"#{action}_actuator", class_name: 'Actuator'
    
    validates :"#{action}_action", numericality: {greater_than_or_equal_to: 0, less_than: ACTIONS.size, only_integer: true}, allow_nil: true
    
    serialize :"#{action}_params"
    
    class_eval %Q/
      validate do
        validate_action(:#{action})
      end
      
      def #{action}_action_name
        #{action}_action.nil? ? nil : ACTIONS[#{action}_action]
      end
    /
        
  end

  def value_required?
    ["more than", "less than", "equals"].include?(self.operation)
  end
  
  def to_s
    cond = self.operation == "sensor failure" ? "Failure of #{self.sensor.to_s}" : "#{self.sensor.to_s} #{self.operation} #{self.value}"
    self.description.to_s.strip != "" ? "#{self.description} (#{cond})" : cond 
  end
  
  def check
    return unless self.enabled
    return unless self.active ^ self.alarm?
    self.update_attribute(:active, !self.active)
    execute_action(self.active? ? :activate : :restore)
  end
  
  def alarm?
    case self.operation
    when "more than"
      self.sensor.last_value && self.sensor.last_value > self.value     
    when "less than"
      self.sensor.last_value && self.sensor.last_value < self.value
    when "equals"
      self.sensor.last_value && self.sensor.last_value == self.value
    when "sensor failure"
      self.sensor.last_seen_at && !self.sensor.alive?
    end     
  end
  
  def execute_action(action)
    p = self.send("#{action}_params")
    case self.send("#{action}_action_name")
      when 'Set Actuator'
        self.send("#{action}_actuator").value = p['value']
    end
  end
  
  def validate_action(action)
    p = self.send("#{action}_params")
    case self.send("#{action}_action_name")
      when 'Set Actuator'
        a = self.send("#{action}_actuator")
        errors.add(:"#{action}_actuator", "can't be blank") unless a
        errors.add(:"#{action}_params", "actuator value can't be blank") unless p && p['value']  
        errors.add(:"#{action}_params", "actuator value is invalid") if p && p['value'] && a && !a.valid_value?(p['value'])   
    end
  end
  
  def self.detect_sensor_failures
    self.where("enabled and operation = 3").each(&:check)
  end
end