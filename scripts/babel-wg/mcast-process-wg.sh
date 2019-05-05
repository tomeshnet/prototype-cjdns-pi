#!/bin/bash
source /etc/wg
SOCAT_PEERADDR=$(echo "$SOCAT_PEERADDR" | tr -d \[ | tr -d \]) #Remote
SOCAT_SOCKADDR=$(echo "$SOCAT_SOCKADDR" | tr -d \[ | tr -d \]) #Local
LOCAL=$(echo $SOCAT_SOCKADDR  | tr -d \[ | tr -d \] | tr -d \:)
IFACE=$(cat /proc/net/if_inet6  | grep $LOCAL  | awk '{print $6}')
#echo $SOCAT_SOCKADDR
#/proc/net/if_inet6

if [[ "$SOCAT_SOCKADDR" == "$SOCAT_PEERADDR" ]]; then
   exit 0
fi

read -r line
A="$(cut -d'|' -f1 <<<"$line")"
if [[ "$A" == "WG" ]]; then
    peerPub="$(cut -d'|' -f2 <<<"$line")"
    if [ -z "$(wg 2>&1  |  grep "${peerPub}")" ]; then
        key=$(echo $peerPub | sha512sum  | awk '{print $1}' | sha512sum | awk '{print $1}')
        ipv6=0${key:0:31}
        ip=${ipv6:0:4}:${ipv6:4:4}:${ipv6:8:4}:${ipv6:12:4}:${ipv6:16:4}:${ipv6:20:4}:${ipv6:24:4}:${ipv6:28:4}
        ip="$(echo $ip | cut -d ":" -f5-8)"
        wg set wg0 listen-port 1010 private-key /etc/wg.key peer $peerPub endpoint [$SOCAT_PEERADDR%$IFACE]:1010 persistent-keepalive 60 allowed-ips fe80::${ip}/128,ff02::1:6/128,400::/12
    fi
fi
