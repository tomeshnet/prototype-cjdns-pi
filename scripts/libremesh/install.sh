#!/bin/bash

ARCH="$(uname -m)" 
case "$ARCH" in
  x86_64)
    ARCH="amd64"
  ;;
  i386 | i586 | i686 )
    ARCH="386"
  ;;
  armv7l)
    ARCH="armv7";
  ;;
  armv6l)
      ARCH="armv6";
  ;;
  aarch64)
    ARCH="arm64";
  ;;
  *)
    echo "Unknown Arch"
    exit 1
  ;;
esac

# Set default settings for libremesh
./set-defaults.sh

# Update configs of libremesh
./set-config.sh

# Install batman
sudo apt-get install -y batctl

# Change mesh-point settings to use channel 11 (Libremesh default) and set meshname of LiMe
sudo confset general frequency 2462 /etc/mesh.conf
sudo confset general mesh-name LiMe /etc/mesh.conf

# Always load batman on boot
echo batman-adv >> /etc/modules

# Install Babled from meshwithme repos
wget http://meshwithme.online/deb/repos/apt/debian/pool/main/c/confset/confset_1_all.deb
sudo dpkg -i confset_1_all.deb
wget http://meshwithme.online/deb/repos/apt/debian/pool/main/b/babeld/babeld_1.9.1-dirty_${ARCH}.deb
sudo dpkg -i babeld_1.9.1-dirty_${ARCH}.deb
wget http://meshwithme.online/deb/repos/apt/debian/pool/main/b/babeld-tomesh/babeld-tomesh_1_all.deb
sudo dpkg -i babeld-tomesh_1_all.deb

# Force meshpoint to run at higher mtu  (1560) to prevent fragmentation of batman-adv
echo 'ip link set dev $mesh_dev mtu 1560' >> /usr/bin/mesh-point

# Try to add a second interface to mesh on the tomesh name (channel will still be differnt)
echo 'iw dev $mesh_dev interface add wlan0-tomesh type mesh mesh_id tomesh || true'  >> /usr/bin/mesh-point 

# Generate network config
sudo ./updateConfig.sh
