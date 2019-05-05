#!/bin/bash
source /etc/wg

for int in $(find /sys/class/net/* -maxdepth 1 -print0 | xargs -0 -l basename); do
  if [[ "$int" == "wg"* ]]; then
    ip link del dev $int type wireguard
  fi
done
ip -6 address add dev lo scope link $ipv6/12

mkdir -p /var/run/babel-wg
echo 0 > /var/run/babel-wg/index
echo > /var/run/babel-wg/list
