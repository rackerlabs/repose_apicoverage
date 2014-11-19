#! /bin/bash
sudo apt-get update -y
sudo apt-get install libxml2-dev libxslt-dev openjdk-7-jre ruby-dev build-essential zlib1g-dev -y
sudo apt-get install -y wget curl patch python-pip
sudo pip install gunicorn
sudo pip install httpbin 
sudo nohup gunicorn httpbin:app &
sudo gem install nokogiri
sudo gem install gherkin
sudo java -javaagent:/usr/share/coverage/lib/extras/jolokia-jvm-1.2.3-agent.jar -Dcom.sun.management.jmxremote.port=10011 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.local.only=true -jar /usr/share/repose/repose-valve.jar -c /etc/repose/ &
gem install bundler
cd /usr/share/coverage 
bundle install 
bundle exec rackup
