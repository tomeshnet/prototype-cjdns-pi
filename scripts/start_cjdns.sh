#!/bin/sh

cd /home/pi

# Get cjdns
if ! [ -d "cjdns" ]; then
	git clone https://github.com/hyperboria/cjdns.git
fi
cd cjdns

# Build cjdns with optimizations
if ! [ -x "cjdroute" ]; then
	./clean && NO_TEST=1 Seccomp_NO=1 CFLAGS="-s -static -Wall -mfpu=neon -mcpu=cortex-a7 -mtune=cortex-a7 -fomit-frame-pointer -marm" ./do
fi

# Generate cjdns node configurations
if ! [ -f "cjdroute.conf" ]; then
	./cjdroute --genconf > cjdroute.conf
fi

# Run cjdns
sudo ./cjdroute < cjdroute.conf
