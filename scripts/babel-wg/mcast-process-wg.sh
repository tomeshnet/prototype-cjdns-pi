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
root@tomesh-8585:/usr/local/sbin# cat mcast-process-wg.sh
#!/bin/bash
SOCAT_PEERADDR=$(echo "$SOCAT_PEERADDR" | tr -d \[ | tr -d \]) #Remote
SOCAT_SOCKADDR=$(echo "$SOCAT_SOCKADDR" | tr -d \[ | tr -d \]) #Local
LOCAL=$(echo $SOCAT_SOCKADDR  | tr -d \[ | tr -d \] | tr -d \:)
IFACE=$(cat /proc/net/if_inet6  | grep $LOCAL  | awk '{print $6}')


function getIndex {
      index=$(cat /var/run/babel-wg/list | grep $1 | awk '{print $1}' | head -n 1)
      echo $index
}
#/proc/net/if_inet6

if [[ "$SOCAT_SOCKADDR" == "$SOCAT_PEERADDR" ]]; then
   exit 0
fi

set -x

read -r line


if [[ "$line" != *"|"* ]]  ; then
   exit 0
fi


#A="$(cut -d'|' -f1 <<<"$line")"
A="$(echo $line | cut -d'|' -f1)"


if [[ "$A" == "WG" ]]; then
      peerPub="$(cut -d'|' -f2 <<<"$line")"

      index=$(getIndex $peerPub)
      if [ -z $index ]; then
          index=$(cat /var/run/babel-wg/index)
          index=$((index+1))
          echo $index "${peerPub}" >> /var/run/babel-wg/list
          echo $index > /var/run/babel-wg/index
          echo "WGPORT|$publicKey|101$index" |  socat - UDP6-datagram:[$SOCAT_PEERADDR%$IFACE]:1234
      fi
fi

if [[ "$A" == "WGPORT" ]]; then


exit 0
    peerPub="$(cut -d'|' -f2 <<<"$line")"
    if [ -z "$(wg 2>&1  |  grep "${peerPub}")" ]; then
        key=$(echo $peerPub | sha512sum  | awk '{print $1}' | sha512sum | awk '{print $1}')
        ipv6=0${key:0:31}
        ip=${ipv6:0:4}:${ipv6:4:4}:${ipv6:8:4}:${ipv6:12:4}:${ipv6:16:4}:${ipv6:20:4}:${ipv6:24:4}:${ipv6:28:4}
        ip="$(echo $ip | cut -d ":" -f5-8)"

	source /etc/wg

	ip link add dev wg${index} type wireguard
	ip link  set dev wg${index} up
#	wg set wg${index} listen-port 1010

	if [ -z "$(ip addr show dev wg${index}  | grep inet6\ fe)" ]; then
	          ip="$(echo $ipv6 | cut -d ":" -f5-8)"
	          ip address add dev wg${index} scope link fe80::${index}:${ip}/64
	fi

        wg set wg${index} listen-port 101${index} private-key /etc/wg.key peer $peerPub endpoint [$SOCAT_PEERADDR%$IFACE]:1010 persistent-keepalive 60 allowed-ips ::/0
    fi
fi
