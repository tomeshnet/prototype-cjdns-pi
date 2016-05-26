#!/bin/sh

set -e

cd /home/pi

# Get tools
if ! [ "$(which git)" ] || ! [ "$(which nodejs)" ] || ! [ "$(which iperf3)" ]; then
	sudo apt-get update
	sudo apt-get install git nodejs iperf3
fi

# Get cjdns
if ! [ -d "cjdns" ]; then
	git clone https://github.com/cjdelisle/cjdns.git
fi
cd cjdns

# Build cjdns with optimizations
if ! [ -x "cjdroute" ]; then
	./clean
	git checkout cjdns-v17.3
	NO_TEST=1 Seccomp_NO=1 CFLAGS="-s -static -Wall -mfpu=neon -mcpu=cortex-a7 -mtune=cortex-a7 -fomit-frame-pointer -marm" ./do
fi

# Generate cjdns node configurations
if ! [ -f "cjdroute.conf" ]; then
	./cjdroute --genconf > cjdroute.conf
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
