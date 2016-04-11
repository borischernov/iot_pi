# 
# Initialize GSM modem, if any
#

if SETTINGS[:gsm_modem] && SETTINGS[:gsm_modem][:port]
  require 'rubygsm'

  begin
    $gsm_modem = Gsm::Modem.new(SETTINGS[:gsm_modem][:port], baudrate: SETTINGS[:gsm_modem][:baudrate] || 115200, log_level: :none)
    $gsm_modem.use_pin(SETTINGS[:gsm_modem][:pin]) if $gsm_modem.pin_required?
  rescue
    $gsm_modem = nil
  end
end 
