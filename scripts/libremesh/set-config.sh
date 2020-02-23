#!/bin/bash

# Read core paramaters 
BABELD_VLAN=$(confget -f /etc/mesh-libre.conf -s libremesh "BABELD_VLAN")
SSID=$(confget -f /etc/mesh-libre.conf -s libremesh "SSID")
MAC=$(confget -f /etc/mesh-libre.conf -s libremesh "MAC")

# MD5SUM hash for SSID will be used for the calculations (NOTE: ends in \n)
SSIDHASH="$(echo ${SSID} | md5sum | awk '{print $1}')"
sudo confset libremesh SSIDHASH ${SSIDHASH} /etc/mesh-libre.conf

# First 4 bytes of the HASHED SSID will be used for differnt network settings
# We convert HEX to DEC
N1=$( printf "%d" "0x${SSIDHASH:0:2}" )
N2=$( printf "%d" "0x${SSIDHASH:2:2}" )
N3=$( printf "%d" "0x${SSIDHASH:4:2}" )
N4=$( printf "%d" "0x${SSIDHASH:6:2}" )

# Last 3 bytes of the MAC (make up the node name)
NODEID=$(echo $MAC | cut -f 4 -d \:)$(echo $MAC | cut -f 5 -d \:)$(echo $MAC | cut -f 6 -d \:)
sudo confset libremesh NODEID ${NODEID} /etc/mesh-libre.conf

M1=$( printf "%d" "0x${NODEID:0:2}" )
M2=$( printf "%d" "0x${NODEID:2:2}" )
M3=$( printf "%d" "0x${NODEID:4:2}" )

BATMAN_VLAN=$(( 29 + $(( N1 - 13 )) % 254 ))
sudo confset libremesh BATMAN_VLAN ${BATMAN_VLAN} /etc/mesh-libre.conf
 
NODEIP=10.$N1.$M2.$M3
sudo confset libremesh NODEIP ${NODEIP} /etc/mesh-libre.conf
