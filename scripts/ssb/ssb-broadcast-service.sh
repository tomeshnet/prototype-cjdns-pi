#!/bin/bash
# shellcheck disable=SC2162
true

while true; do
    if ! [ -z "$id" ]; then
         for int in $(find /sys/class/net/* -maxdepth 1 -print0 | xargs -0 -l basename); do
            ip=$(ip addr show "${int}" | grep -v inet6 | grep -v '127.0.0.1' |grep inet | head -n 1 | awk '{print $2}' | awk -F "/" '{print $1}')
            if ! [ -z "$ip" ]; then
                echo -n "net:$ip:8008~shs:$id" | sudo socat -T 1 - "UDP4-DATAGRAM:255.255.255.255:8008,broadcast,so-bindtodevice=${int}" &
            fi
        done

        # Manual cjdns peer unicast
        if [ "$(which cjdroute)" ]; then
            mycjdnsip=$(grep -m 1 '"ipv6"' /etc/cjdroute.conf | awk '{ print $2 }' | sed 's/[",]//g')
            # shellcheck disable=SC2102,SC2046
            read -a peers <<< $(sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($3 == "ESTABLISHED") print $2 }' | awk -F. '{print $6".k"}' | xargs)
            for peer in "${peers[@]}"; do
                ip=$(sudo /opt/cjdns/publictoip6 "$peer")
                # shellcheck disable=SC2102
                echo -n "net:$mycjdnsip:8008~shs:$id" | sudo socat -T 1 - UDP6-DATAGRAM:[$ip]:8008
            done  
        fi

        # Add yggdrasil direct peers
        if [ "$(which yggdrasil)" ]; then
            myyggip=$(yggdrasilctl getself | grep address | awk '{print $3}')
            read -a peers  <<< "$(sudo yggdrasilctl getPeers | grep -v "(self)" | awk '{print $1}' | grep -v bytes_recvd | xargs)"
            for peer in "${peers[@]}"; do
                # shellcheck disable=SC2102
                echo -n "net:$myyggip:8008~shs:$id" | sudo socat -T 1 - UDP6-DATAGRAM:[$peer]:8008
            done
        fi
    else
        id=$(sbot whoami | grep id | awk -F "\"" '{print $4}' | sed 's/.ed25519//' | sed 's/@//')
    fi
    sleep 5
done
