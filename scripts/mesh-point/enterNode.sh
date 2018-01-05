#!/bin/sh

int="$1"
if [ ! -f "/sys/class/net/br-enter/type" ]; then
   brctl addbr br-enter
   ifconfig br-enter 10.0.0.1/24 up
   systemctl radvd restart

   # Enable forwarding if not already
   sysctl -w net.ipv4.ip_forward=1
   sysctl -w net.ipv6.conf.all.forwarding=1

   iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to$
   ip6tables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-t$

   # Forward all IPv4 traffic from the internal network to the eth0 device and$
   iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE

   # Forward all IPv6 traffic from the internal network to the tun0 device and$
   ip6tables -t nat -A POSTROUTING -o tun+ -j MASQUERADE

   fi
brctl addif br-enter $int

