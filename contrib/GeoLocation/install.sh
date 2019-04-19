#!/bin/bash
sudo apt-get install -y jq
sudo cp "nodeinfo-geolocation" /opt/tomesh/nodeinfo.d/geolocation
sudo chmod +x /opt/tomesh/nodeinfo.d/geolocation
