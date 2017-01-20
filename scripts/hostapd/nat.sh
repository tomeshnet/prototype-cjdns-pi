#!/bin/sh

# Forward all IPv4 traffic from the internal network to the eth0 device and mask with the eth0 external IP address
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Forward all IPv6 traffic from the internal network to the tun0 device and mask with the tun0 external IP address
ip6tables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
