#!/bin/sh

# Install custom babeld
wget https://github.com/althea-mesh/babeld/archive/0.1.1.zip
unzip 0.1.1.zip
cd babeld-0.1.1
make
sudo cp babeld /usr/bin/babeld
cd ..

# Install wireguard  
sudo apt-get install libmnl-dev libelf-dev build-essential pkg-config raspberrypi-kernel-headers
git clone https://git.zx2c4.com/WireGuard
cd WireGuard/src
make
make install
