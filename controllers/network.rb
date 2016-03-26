get '/network' do
  @interfaces = iface_list
  erb :'network/settings'
end

post '/network' do
  @errors = params[:interfaces].map do |int, cfg|
    e = cfg_errors(cfg)
    e.any? ? "#{int}: #{e.join("; ")}" : nil
  end.compact
  
  if @errors.any?
    @interfaces = params[:interfaces].map { |k,v| v[:name] = k; v[:type] = v.has_key?('ssid') ? :wireless : :wired; v }
    return erb :'network/settings'
  end 
  
  write_config(params[:interfaces])
  
  redirect to('/')
end

def cfg_errors(cfg)
  errors = []
  if cfg[:mode] == 'static'
    errors.push "invalid address" unless cfg[:address].to_s.strip =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
    errors.push "invalid netmask" unless cfg[:netmask].to_s.strip =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
  end
  if cfg.has_key?('ssid') && cfg[:mode] != 'unconfigured' 
    errors.push "ssid should be specified" if cfg[:ssid].to_s.strip == ""
    if cfg[:encryption] != 'none'
      errors.push "password should be specified" if cfg[:password].to_s.strip == ""
    end
  end
  errors 
end

def write_config(cfg)
  config = "auto lo\niface lo inet loopback\n\n"
  
  config += cfg.map do |ifc, c|
    next if c[:mode] == 'unconfigured'
    lines = []
    
    lines << "auto #{ifc}"
    lines << "allow-hotplug #{ifc}"
    lines << "iface #{ifc} inet #{c[:mode] == 'static' ? 'static' : 'manual'}"
    
    if c[:mode] == 'static'
      lines << "\taddress #{c[:address]}"
      lines << "\tnetmask #{c[:netmask]}"
      lines << "\tgateway #{c[:gateway]}" if c[:gateway].to_s.strip != ""
      lines << "\tdns-nameservers #{c[:nameservers]}" if c[:nameservers].to_s.strip != ""
    end
    
    if c.has_key?("ssid")
      if c[:encryption] == 'wpa'
        lines << "\twpa-ssid \"#{c[:ssid]}\""
        lines << "\twpa-psk \"#{c[:password]}\""
      else
        lines << "\twireless-essid \"#{c[:ssid]}\""
        lines << "\twireless-key \"#{c[:password]}\"" if c[:password].to_s.strip != ""
      end
    end
    
    lines.join("\n")
  end.compact.join("\n\n") + "\n"
  
  File.open("/etc/network/interfaces",'w') { |f| f.write config }
  `/usr/sbin/service networking restart` 
end

def iface_list
  ifaces = `/sbin/iwconfig 2>&1`.scan(/^[^\s].*$/).select { |l| !(l =~ /^lo\s/) }.map { |i| i =~ /^(.*?)\s/; [$1, i.include?("no wireless") ? :wired : :wireless] }.map do |i, t|
    cfg = iface_cfg(i) || {}
    cfg[:name] = i
    cfg[:type] = t
    cfg
  end
end

def iface_cfg(ifname)
  cfg = File.read("/etc/network/interfaces").gsub(/^#.*$/,'').split("\n\n").detect { |l| l.include?("iface #{ifname}") }
  return nil unless cfg
  cfg =~ /^\s*address\s+(.*?)\s*$/
  address = $1
  cfg =~ /^\s*netmask\s+(.*?)\s*$/
  netmask = $1
  cfg =~ /^\s*gateway\s+(.*?)\s*$/
  gateway = $1
  cfg =~ /^\s*dns-nameservers\s+(.*?)\s*$/
  nameservers = $1
  # WPA
  cfg =~ /^\s*wpa-ssid\s+\"?(.*?)\"?\s*$/
  ssid ||= $1
  cfg =~ /^\s*wpa-psk\s+\"?(.*?)\"?\s*$/
  password ||= $1
  # WEP
  cfg =~ /^\s*wireless-essid\s+\"?(.*?)\"?\s*$/
  ssid ||= $1
  cfg =~ /^\s*wireless-key\s+\"?(.*?)\"?\s*$/
  password ||= $1
  encryption = cfg.include?("wpa-ssid") ? :wpa : (cfg.include?("wireless-essid") ? :wep : nil)
  {
    mode: cfg.include?("iface #{ifname} inet manual") ? :dhcp : :static,
    address: address,
    netmask: netmask,
    gateway: gateway,
    nameservers: nameservers,
    ssid: ssid,
    password: password,
    encryption: encryption
  }
end

