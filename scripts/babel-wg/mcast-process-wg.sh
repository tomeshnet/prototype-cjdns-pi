#!/bin/bash
SOCAT_PEERADDR=$(echo "$SOCAT_PEERADDR" | tr -d \[ | tr -d \]) #Remote
SOCAT_SOCKADDR=$(echo "$SOCAT_SOCKADDR" | tr -d \[ | tr -d \]) #Local
LOCAL=$(echo $SOCAT_SOCKADDR  | tr -d \[ | tr -d \] | tr -d \:)
IFACE=$(cat /proc/net/if_inet6  | grep $LOCAL  | awk '{print $6}')

function getIndex {
      index=$(cat /var/run/babel-wg/list | grep $1 | awk '{print $1}' | head -n 1)
      echo $index
}
function createIndex {
   index=$(cat /var/run/babel-wg/index)
   index=$((index+1))
   echo $index "${peerPub}" >> /var/run/babel-wg/list
   echo $index > /var/run/babel-wg/index
   echo $index
}

if [[ "$SOCAT_SOCKADDR" == "$SOCAT_PEERADDR" ]]; then
   exit 0
fi

read -r line

if [[ "$line" != *"|"* ]]  ; then
   exit 0
fi


#A="$(cut -d'|' -f1 <<<"$line")"
A="$(echo $line | cut -d'|' -f1)"

source /etc/wg

if [[ "$A" == "WG" ]]; then
      peerPub="$(echo $line | cut -d'|' -f2)"
      index=$(getIndex $peerPub)
      if [ -z $index ]; then
         index=$(createIndex);
      fi
      echo "WGPORT|$publicKey|101$index" |  socat - UDP6-datagram:[$SOCAT_PEERADDR%$IFACE]:1234
fi


if [[ "$A" == "WGPORT" || "$A" == "WGPORTACK" ]]; then

    echo wglink - Receive $A  >> /var/log/babel-wg
    peerPub="$(cut -d'|' -f2 <<<"$line")"
    peerPort="$(cut -d'|' -f3 <<<"$line")"

    index=$(getIndex $peerPub)
    if [ -z $index ]; then
         index=$(createIndex);
    fi

    if [ ! -z "$(wg 2>&1  |  grep "${peerPub}")" ]; then
        testPort=$(wg | grep -A1 ${peerPub} | tail -n1 | rev | cut -d ":" -f1 | rev)
        if [[ $testPort != $peerPort ]]; then

            for int in $(find /sys/class/net/* -maxdepth 1 -print0 | xargs -0 -l basename); do
                if [[ "$int" == "wg"* ]]; then
                    wg=$(wg show $int | grep $peerPub)
                    if [ ! -z "$wg" ]; then
                        echo wglink - Deleteing $wg due to port mismatch $testPort != $peerPort >> /var/log/babel-wg
                        ip link del dev $int type wireguard
                    fi
                fi
            done
        fi
    fi

    if [ -z "$(wg 2>&1 | grep "${peerPub}")" ]; then

        echo wglink - adding wg${index} 101$index $peerPort >> /var/log/babel-wg
        ip link add dev wg${index} type wireguard
        ip link set dev wg${index} up
        wg set wg${index} listen-port 101$index
        wg set wg${index} listen-port 101${index} private-key /etc/wg.key peer $peerPub endpoint [$SOCAT_PEERADDR%$IFACE]:$peerPort persistent-keepalive 60 allowed-ips ::/0

        # Add Interface to WG
        echo "interface wg${index}" |  socat - TCP6:[::1]:999 > /dev/null

         ip -6 address add dev  wg${index} scope link $ipv6/12

#       if [ -z "$(ip addr show dev wg${index}  | grep inet6\ fe)" ]; then
#          ip="$(echo $ipv6 | cut -d ":" -f5-8)"
#          ip address add dev wg${index} scope link fe80::${index}:${ip}/64
#       fi
   fi
   if [[ "$A" != "WGPORTACK" ]]; then
      echo wglink - Send ACK wg${index}  >> /var/log/babel-wg
      echo "WGPORTACK|$publicKey|101$index" |  socat - UDP6-datagram:[$SOCAT_PEERADDR%$IFACE]:1234
   fi

fi
