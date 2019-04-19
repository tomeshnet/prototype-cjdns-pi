#!/bin/bash
sudo apt-get install -y jq
sudo cp "nodeinfo-geolocation" /opt/tomesh/nodeinfo.d/00_geolocation
sudo chmod +x /opt/tomesh/nodeinfo.d/00_geolocation
