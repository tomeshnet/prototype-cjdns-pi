#!/bin/bash

cp wlan0-bat /tmp/wlan0.${BATMAN_VLAN}
sed -i "s/__BATMAN_VLAN__/$BATMAN_VLAN/g" "/tmp/wlan0.${BATMAN_VLAN}"
sudo mv /tmp/wlan0.${BATMAN_VLAN} /etc/network/interfaces.d/wlan0.${BATMAN_VLAN}

cp bat0 /tmp/bat0
sed -i "s/__BATMAN_VLAN__/$BATMAN_VLAN/g" "/tmp/bat0"
sed -i "s/__NODEIP__/$NODEIP/g" "/tmp/bat0"
sudo mv /tmp/bat0 /etc/network/interfaces.d/bat0

cp wlan0-bat /tmp/wlan0.${BABELD_VLAN}
sed -i "s/__BABELD_VLAN__/$BABELD_VLAN/g" "/tmp/wlan0.${BABELD_VLAN}"
sed -i "s/__NODEIP__/$NODEIP/g" "/tmp/wlan0.${BABELD_VLAN}"
sudo mv /tmp/wlan0.${BABELD_VLAN} /etc/network/interfaces.d/wlan0.${BABELD_VLAN}

# ETH VLAN for layer 3 BABELD meshing
cp eth0-babeld /tmp/eth0.${BABELD_VLAN}
sed -i "s/__BABELD_VLAN__/$BABELD_VLAN/g" "/tmp/eth0.${BABELD_VLAN}"
sed -i "s/__NODEIP__/$NODEIP/g" "/tmp/eth0.${BABELD_VLAN}"
sudo mv /tmp/eth0.${BABELD_VLAN} /etc/network/interfaces.d/eth0.${BABELD_VLAN}

# ETH VLAN for layer 3 BABELD meshing
cp babeld.conf /tmp/babeld.conf
sed -i "s/__BABELD_VLAN__/$BABELD_VLAN/g" "/tmp/babeld.conf"
sudo mv /tmp/babeld.conf /etc/babeld.d/libremesh
