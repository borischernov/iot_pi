require 'yaml'
require File.join(APP_ROOT,'/lib/firmware_loader')

get '/firmware' do
  @settings = get_settings
  @firmwares = scan_firmwares
  erb :'firmware/form'
end

post '/firmware' do
  @settings = get_settings.merge(params[:settings])
  save_settings(@settings)

  headers "Transfer-Encoding" => "chunked"
  stream do |out|
    out << erb(:'firmware/upload')
    loader = FirmwareLoader.new(lambda { |str| out << "<script type=\"text/javascript\">$('#output').append(#{"#{str}\n".to_json})</script>\n" })
    loader.flash_nodemcu
    fw_dir = File.join(APP_ROOT, 'firmware', params[:firmware])
    cfg = eval(File.read(File.join(fw_dir, 'firmware.rb')))
    loader.send_firmware(fw_dir, cfg['files'], @settings)
    out << "<script type=\"text/javascript\">$('#back').show()</script>\n"
  end
end

def get_settings
  YAML.load(File.read(File.join(APP_ROOT, 'settings/settings.yml'))) rescue {}
end

def save_settings(settings)
  File.open(File.join(APP_ROOT, 'settings/settings.yml'), 'w') { |f| f.write settings.to_yaml }
end

def scan_firmwares
  fw_dir = File.join(APP_ROOT, 'firmware')
  Dir.entries(fw_dir).select { |d| !(d =~ /^\./) && File.directory?(File.join(fw_dir, d))}.map do |d|  
    cfgfile = File.join(fw_dir, d, "firmware.rb")
    next unless File.exists?(cfgfile)
    cfg = eval(File.read(cfgfile))
    next unless cfg[:name]
    [d, cfg[:name]]
  end.compact
end

module Sinatra
  module Helpers
    class Stream
      def each(&front)
        @front = front
        callback do
          @front.call("0\r\n\r\n")
        end

        @scheduler.defer do
          begin
            @back.call(self)
          rescue Exception => e
            @scheduler.schedule { raise e }
          end
          close unless @keep_open
        end
      end

      def <<(data)
        @scheduler.schedule do
          size = data.to_s.bytesize
          @front.call([size.to_s(16), "\r\n", data.to_s, "\r\n"].join)
        end
        self
      end
    end
  end
end
