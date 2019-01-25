#!/bin/bash

while true; do
    while read -r id; do
        for int in $(find /sys/class/net/* -maxdepth 1 -print0 | xargs -0 -l basename); do
            ip=$(ip addr show "$int" | grep -v inet6 | grep -v '127.0.0.1' |grep inet | head -n 1 | awk '{print $2}' | awk -F "/" '{print $1}')
            if ! [ -z "$ip" ]; then
                echo -n "net:$ip:8008~shs:$id" | sudo socat -T 1 - "UDP4-DATAGRAM:255.255.255.255:8008,broadcast,so-bindtodevice=$int" &
            fi
        done
    done <<< "$(sudo cat /var/www/backend/keys/* | grep id | grep -v "#" | awk '{print $2}' | tr -d '"' | sed 's/.ed25519//' | sed 's/@//')"
    sleep 5
done
