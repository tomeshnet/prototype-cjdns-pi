#!/bin/bash

source /etc/wg

while true; do
  for int in $(find /sys/class/net/* -maxdepth 1 -print0 | xargs -0 -l basename); do
    if [[ "$int" == "eth"* ]]; then
      echo "WG|$publicKey" |  socat - UDP6-datagram:[ff02::1%$int]:1234
    fi
    if [[ "$int" == "wlan"* ]]; then
      echo "WG|$publicKey" |  socat - UDP6-datagram:[ff02::1%$int]:1234
    fi
  done
  sleep 30
done
