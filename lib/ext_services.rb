require 'net/http'
require 'uri'

module EasyIotCloud
  def self.send_data(ident, data)
    uri = URI.parse("http://cloud.iot-playground.com:40404/RestApi/SetParameter/#{ident}/#{data}")
    Net::HTTP.post_form(uri, {})
  end
end

module Thingspeak
  def self.send_data(ident, data)
    uri = URI.parse("http://api.thingspeak.com/update.json")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"api_key" => ident, "field1" =>  data})
    http.request(request)    
  end
end