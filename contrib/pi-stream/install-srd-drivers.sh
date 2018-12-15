#!/bin/sh

# Install SDR drivers
sudo apt-get install -y cmake git libusb-1.0-0-dev
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make
sudo make install
sudo ldconfig

# Make drivers work
sudo cp ../rtl-sdr.rules /etc/udev/rules.d/
echo blacklist dvb_usb_rtl28xxu | sudo tee /etc/modprobe.d/blacklist-rtl.conf > /dev/null
