#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source shared/confset/install

#Enable test repo
echo deb http://meshwithme.online/deb/repos/apt/debian stretch main | sudo tee /etc/apt/sources.list.d/tomesh.list

sudo apt-get update
sudo apt-get install babeld

# Dont announce yggdrasil of cjdns addresses
sudo systemctl stop babeld
echo redistribute deny local ip 200::/7 | sudo tee --append /etc/babeld.conf
echo redistribute deny local ip 300::/7 | sudo tee --append /etc/babeld.conf
echo redistribute deny local ip fc00::/8 | sudo tee --append /etc/babeld.conf
# Dont announce natted 10.0.0.1 from access point
echo redistribute deny local ip 10.0.0.1/32 | sudo tee --append /etc/babeld.conf

# enable babeld on mesh interface
echo interface wlan0 | sudo tee --append /etc/babeld.conf

# Attempt to find eth0's mac address even if predictive naming is on
if [ -f "/sys/class/net/eth0/address" ]; then
    mac=$(cat /sys/class/net/eth0/address )
else
   if ! [ -z "$(sudo dmesg | grep eth0 | grep renamed | awk '{print $8}') | grep eth0" ]; then
       mac=$(cat /sys/class/net/$(sudo dmesg | grep eth0 | grep renamed | awk '{print $5}' | tr -d \: )/address);
   fi
fi

# Generate IPv4 address from mac address
# Taken from Pitmesh's model
if ! [ -z $mac ]; then
  ip2=$(printf "%d" "0x$(echo $mac | cut -f 4 -d \:)")
  ip3=$(printf "%d" "0x$(echo $mac | cut -f 5 -d \:)")
  ip4=$(printf "%d" "0x$(echo $mac | cut -f 6 -d \:)")
  ip2=$(expr $ip2 % 32 + 96)
  ip4=$(expr $ip4 - $(expr $ip4 % 64 - $ip4 % 32))
  IPV4="10.$ip2.$ip3.$ip4"
  IPAP="172.$(expr $ip2 % 16 + 16).$ip3.1"
  NODEID=$ip3-$ip4
  
  sudo confset general ipv4 "$IPV4" /etc/mesh.conf

fi

sudo systemctl start babeld
