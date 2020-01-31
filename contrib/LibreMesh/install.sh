
# LibreMesh Default Layer 3 Babled Network
BABELD_VLAN=17 

# Default SSID for LibreMesh is LibreMesh.org
# It is used to define NETWORK related settings
SSID="LibreMesh.org" #Default SSID
# MD5SUM hash for SSID will be used for the calculations
SSIDHASH=$(echo ${SSID} | md5sum) # Hash of the SSID

# First 4 bytes of the HASHED SSID will be used for differnt network settings
N1=$( printf "%d" "0x${SSIDHASH:0:2}" )
N2=$( printf "%d" "0x${SSIDHASH:2:2}" )
N3=$( printf "%d" "0x${SSIDHASH:4:2}" )
N4=$( printf "%d" "0x${SSIDHASH:6:2}" )

# MAC address of ethernet. Used to identify NODE specific settings
MAC=$(cat /sys/class/net/eth0/address ) # Get Mac
# Last 3 bytes of the MAC make up the node name
NODEID=$(echo $MAC | cut -f 4 -d \:)$(echo $MAC | cut -f 5 -d \:)$(echo $MAC | cut -f 6 -d \:)
M1=$( printf "%d" "0x${NODEID:0:2}" )
M2=$( printf "%d" "0x${NODEID:2:2}" )
M3=$( printf "%d" "0x${NODEID:4:2}" )

# BATMAN-ADV VLAN setting
# Each Unique SSID has (we hope) a Unique VLANID so the two networks wont mesh together layer2
# Lots of legacy things in this calculations so its wierd
# BATMAN-ADV vlan is 29 + (N1 - 13) % 254
# Notes:
# N1-13 = 0 on Default Setups
# 29 is added to allow for lower VLANS being Layer 2 (i think)
# % 254 makes sure the number is between 0-254
BATMAN_VLAN=$(( 29 + $(( N1 -13 )) % 254 ))

NODEIP=10.$N1.$M2.$M3

# Install batman
apt-get install -y batctl


# Change to channel 11 and set meshname the LiMe
confset general frequency 2462 /etc/mesh.conf
confset general mesh-name LiMe /etc/mesh.conf


# Always load batman on boot
echo batman-adv >> /etc/modules

# WLAN VLAN for layer 2 BATMAN 
echo <<"EOF"> /etc/network/interfaces.d/wlan0.${BATMAN_VLAN}
auto wlan0.${BATMAN_VLAN}
iface wlan0.${BATMAN_VLAN} inet manual
post-up ip link del wlan0.${BATMAN_VLAN}
post-up ip link add link wlan0 name wlan0.${BATMAN_VLAN} type vlan proto 802.1ad id ${BATMAN_VLAN}
post-up batctl if add wlan0.${BATMAN_VLAN}
post-up ip link set wlan0.${BATMAN_VLAN} up
EOF

# WLAN VLAN for layer 3 BABELD meshing
echo <<"EOF"> /etc/network/interfaces.d/wlan0.${BABELD_VLAN}
auto wlan0.${BABELD_VLAN}
iface wlan0.${BABELD_VLAN} inet manual
   post-up ip link del wlan0.${BABELD_VLAN}
   post-up ip link add link wlan0 name wlan0.${BABELD_VLAN} type vlan proto 802.1ad id ${BABELD_VLAN}
   post-up ip link set wlan0.${BABELD_VLAN} up
   post-up ip addr add ${NODEIP}/16 dev wlan0.${BABELD_VLAN}
EOF

# BAT0 configuration
echo <<"EOF"> /etc/network/interfaces.d/bat0
auto bat0
iface bat0 inet manual
        pre-up batctl if add wlan0.${BATMAN_VLAN}
        post-up ip addr add ${NODEIP}/16 dev bat0
EOF

# ETH VLAN for layer 3 BABELD meshing
echo <<"EOF"> /etc/network/interfaces.d/eth0.${BABELD_VLAN}
auto eth0.${BABELD_VLAN}
iface eth0.${BABELD_VLAN} inet manual
   post-up ip link del eth0.${BABELD_VLAN}
   post-up ip link add link eth0 name eth0.${BABELD_VLAN} type vlan proto 802.1ad id ${BABELD_VLAN}
   post-up ip link set eth0.${BABELD_VLAN} up
   post-up ip addr add ${NODEIP}/16 dev eth0.${BABELD_VLAN}
EOF

# Install BABELD
wget http://meshwithme.online/deb/repos/apt/debian/pool/main/b/babeld/babeld_1.9.1-dirty_armhf.deb
dpkg -i babeld_1.9.1-dirty_armhf.deb 

# Configure BABELD
echo <<"EOF"> /etc/babeld.conf
interface wlan0.${BABELD_VLAN}
interface eth0.${BABELD_VLAN}
local-port 30003
EOF
