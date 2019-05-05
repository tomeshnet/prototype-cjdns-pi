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


if [[ "$A" == "WGPORT" ]]; then

	peerPub="$(cut -d'|' -f2 <<<"$line")"
	peerPort="$(cut -d'|' -f3 <<<"$line")"

	index=$(getIndex $peerPub)
	if [ -z $index ]; then
		index=$(createIndex);
	fi

	if [ -z "$(wg 2>&1  |  grep "${peerPub}")" ]; then

		ip link add dev wg${index} type wireguard
		ip link  set dev wg${index} up
		wg set wg${index} listen-port 101$index
		wg set wg${index} listen-port 101${index} private-key /etc/wg.key peer $peerPub endpoint [$SOCAT_PEERADDR%$IFACE]:$peerPort persistent-keepalive 60 allowed-ips ::/0

		if [ -z "$(ip addr show dev wg${index}  | grep inet6\ fe)" ]; then
			  ip="$(echo $ipv6 | cut -d ":" -f5-8)"
			  ip address add dev wg${index} scope link fe80::${index}:${ip}/64	
		fi
	fi
fi
