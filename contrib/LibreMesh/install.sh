#!/bin/bash

# Install batman
apt-get install -y batctl


# Change to channel 11 and set meshname the LiMe
confset general frequency 2462 /etc/mesh.conf
confset general mesh-name LiMe /etc/mesh.conf


# Always load batman on boot
echo batman-adv >> /etc/modules

# WLAN VLAN for layer 2 BATMAN 
echo <<"EOF"> /etc/network/interfaces.d/wlan0.29
auto wlan0.29
iface wlan0.29 inet manual
post-up ip link del wlan0.29
post-up ip link add link wlan0 name wlan0.29 type vlan proto 802.1ad id 29
post-up batctl if add wlan0.29
post-up ip link set wlan0.29 up
EOF

# WLAN VLAN for layer 3 BABELD meshing
echo <<"EOF"> /etc/network/interfaces.d/wlan0.17
auto wlan0.17
iface wlan0.17 inet manual
   post-up ip link del wlan0.17
   post-up ip link add link wlan0 name wlan0.17 type vlan proto 802.1ad id 17
   post-up ip link set wlan0.17 up
   post-up ip addr add 10.13.183.231/16 dev wlan0.17
EOF

# BAT0 configuration
echo <<"EOF"> /etc/network/interfaces.d/bat0
auto bat0
iface bat0 inet manual
        pre-up batctl if add wlan0.29	
        post-up ip addr add 10.13.183.231/16 dev bat0
EOF

# ETH VLAN for layer 3 BABELD meshing
echo <<"EOF"> /etc/network/interfaces.d/eth0.17
auto eth0.17
iface eth0.17 inet manual
   post-up ip link del eth0.17
   post-up ip link add link eth0 name eth0.17 type vlan proto 802.1ad id 17
   post-up ip link set eth0.17 up
   post-up ip addr add 10.13.183.231/16 dev eth0.17
EOF

# Install BABELD
wget http://meshwithme.online/deb/repos/apt/debian/pool/main/b/babeld/babeld_1.9.1-dirty_armhf.deb
dpkg -i babeld_1.9.1-dirty_armhf.deb 

# Configure BABELD
echo <<"EOF"> /etc/babeld.conf
interface wlan0.17
interface eth0.17
local-port 30003
EOF
