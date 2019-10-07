#!/bin/sh

# Break bridge configured by default

# Disable systemd management of network interfaces except to bring up eth0 with random MAC address
sudo rm -rf /etc/systemd/network/*

sudo tee /etc/systemd/network/10-eth0.network << END
[Match]
Name=eth0
[Network]
DHCP=ipv4
END

sudo tee /etc/systemd/network/10-eth0.link << END
[Match]
MACAddress=f0:ad:4e:03:64:7f
[Link]
MACAddressPolicy=random
END
