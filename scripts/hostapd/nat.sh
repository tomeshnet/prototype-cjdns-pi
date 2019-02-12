#!/bin/sh

# MSS clamp to circumvent issues with Path MTU Discovery
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
ip6tables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Forward all IPv4 traffic from the internal network to the eth0 device and mask with the eth0 external IP address
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Allow all IPv6 traffic routed out tun0 and ygg0 to be masked with their respective external IP address
ip6tables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
