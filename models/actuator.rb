require 'uri'
require 'local_actuators'
require 'timeout'
class Actuator < ActiveRecord::Base
  enum  actuator_type: [ "Switch", "Analog" ]

  before_validation on: :create do
    value_requested ||= '0'
    value_set ||= '0'
  end
  

  validates :ident, presence: true, uniqueness: true
  validate do
    errors.add(:value_requested, "is invalid") unless value_requested_is_valid?       
  end

  def to_s
    self.name || self.ident
  end

  def local?
    self.address.to_s.strip == "local"
  end

  def alive?
    return true if self.local?
    self.last_seen_at && self.last_seen_at > 10.minutes.ago
  end

  def formatted_value(v)
    case self.actuator_type
    when 'Switch'
      v.to_i == 0 ? 'OFF' : 'ON'
    when 'Analog'
      v.to_f
    end
  end

  def valid_value?(value)
    case self.actuator_type
    when 'Switch'
      ['0','1'].include?(value.to_s)
    when 'Analog'
      !!(value.to_s =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/)
    else
      false      
    end
  end

  def value_requested_is_valid?
    valid_value?(self.value_requested)
  end

  def value
    self.value_set == self.value_requested ? 
      formatted_value(self.value_set) : 
      [formatted_value(self.value_set), formatted_value(self.value_requested)].join(" => ")  
  end

  def value=(val)
    self.value_requested = val
    return false unless self.save   # Ensure that validations are run
    self.actuate
  end

  def actuate
    if self.local?
      LocalActuators.set_actuator(self)
    else
      return false if self.address.to_s.strip == ""
      path = "/actuate?" + URI.encode_www_form({ident: self.ident, secret: self.secret, value: self.value_requested})
      begin
        response = Timeout::timeout(3) do
          http = Net::HTTP.new(self.address, 80)
          http.request(Net::HTTP::Get.new(path))
        end
        ok = response.body.to_s.strip == "OK"
        self.update_attribute(:value_set, self.value_requested) if ok
        ok
      rescue
        false
      end
    end
  end

  def self.register(ident, secret, ip)
    return :error if ident.to_s.strip == "" || secret.to_s.strip == "" || ip.to_s.strip == ""
    actuator = Actuator.where(ident: ident).first_or_create do |s|
      s.actuator_type = ident =~ /-dout$/ ? 'Switch' : 'Analog'
      s.active_low = true if s.actuator_type == 'Switch'
      s.value_requested = 0
    end
    actuator.last_seen_at = Time.now
    actuator.address = ip
    actuator.secret = secret
    actuator.save ? :ok : :error
  end

end