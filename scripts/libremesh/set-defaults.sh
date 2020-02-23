#!/bin/bash

# Set Defaults
sudo touch /etc/mesh-libre.conf

# Static libremesh vlan
# Source: https://github.com/libremesh/lime-packages/blob/master/packages/lime-docs/files/lime-example#L41
sudo confset libremesh BABELD_VLAN 17 /etc/mesh-libre.conf

# Default SSID for LibreMesh is "LibreMesh.org"
# It is used to define NETWORK related settings
sudo confset libremesh SSID LibreMesh.org /etc/mesh-libre.conf

# MAC address of ethernet. Used to identify NODE specific settings
sudo confset libremesh MAC $(cat /sys/class/net/eth0/address ) /etc/mesh-libre.conf # Get Mac
