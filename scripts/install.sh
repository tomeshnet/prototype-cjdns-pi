#!/bin/sh

cd /home/pi

# Get tools
if ! [ "$(which git)" ] || ! [ "$(which nodejs)" ] || ! [ "$(which iperf3)" ]; then
	sudo apt-get update
	sudo apt-get install git nodejs iperf3
fi

# Download scripts to bring up this mesh node
if ! [ -d "prototype-cjdns-pi2" ]; then
	git clone https://github.com/tomeshnet/prototype-cjdns-pi2.git
fi

# Configure systemd to start mesh.service on system boot
sudo cp prototype-cjdns-pi2/scripts/mesh.service /lib/systemd/system/mesh.service
sudo chmod 644 /lib/systemd/system/mesh.service
sudo systemctl daemon-reload
sudo systemctl enable mesh.service

# Reboot device
sudo reboot
