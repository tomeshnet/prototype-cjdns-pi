#!/bin/bash

sudo apt install -i libmicrohttpd-dev
mkdir tmp
cd tmp
git clone https://github.com/nodogsplash/nodogsplash.git
cd nodogsplash
make
sudo make install
sudo cp debian/nodogsplash.service /etc/systemd/system
cd ..
rm -rf tmp

cp nodogsplash.conf /etc/nodogsplash/nodogsplash.conf


sudo systemctl enable nodogsplash
sudo systemctl start  nodogsplash
