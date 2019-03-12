#!/bin/sh

# Install batman adv
sudo apt-get install -y batctl

# Configure batman-adv
sudo modprobe batman-adv
sudo batctl if add wlan0
sudo ifconfig bat0 up
