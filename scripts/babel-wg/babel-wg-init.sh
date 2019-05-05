#!/bin/bash

source /etc/wg
ip link del dev wg0 type wireguard || true
ip link add dev wg0 type wireguard
ip link set dev wg0 up
wg set wg0 listen-port 1010
 
if [ -z "$(ip addr show dev wg0  | grep inet6\ fe)" ]; then
	  ip="$(echo $ipv6 | cut -d ":" -f5-8)"
	  ip address add dev wg0 scope link fe80::${ip}/64
fi

ip address add dev wg0 scope link $ipv6/12
