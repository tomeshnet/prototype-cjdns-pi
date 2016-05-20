#!/bin/sh

cd /home/pi/prototype-cjdns-pi2/scripts

# Bring up the Mesh Point interface
./start_meshpoint.sh

# Start cjdns
./start_cjdns.sh
