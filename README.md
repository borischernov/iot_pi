# IoT Pi : IoT server for Raspbery Pi / Banana Pi

### Features
- Collect data from [sensors](https://github.com/borischernov/iot_pi/wiki) connected locally or via ESP8266
- Send sensor readings to [ThingSpeak](https://thingspeak.com) or [EasyIoT Cloud](http://cloud.iot-playground.com/)
- Control actuators connected locally or via ESP8266
- Set alarms on sensor values
  - control actuators
  - send SMS messages via GSM-modem
- Upload firmware to ESP8266 directly from IoT Pi (https://github.com/borischernov/iot_pi/wiki/Programming-ESP8266)

### Installation
~~~~
apt-get install python-serial librrd-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby=1.9.3
gem install bundler
cd /opt
git clone https://github.com/borischernov/iot_pi.git
cd iot_pi
bundle install
rake db:migrate
~~~~
