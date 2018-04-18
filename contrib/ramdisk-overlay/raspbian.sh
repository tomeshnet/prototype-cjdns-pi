#!/bin/sh

wget https://github.com/jacobalberty/root-ro/raw/master/root-ro
wget https://github.com/jacobalberty/root-ro/raw/master/raspi-gpio

chmod 0755 root-ro 
chmod 0755 raspi-gpio

sudo mv root-ro  /etc/initramfs-tools/scripts/init-bottom
sudo mv raspi-gpio /etc/initramfs-tools/hooks

echo overlay | sudo tee --append /etc/initramfs-tools/modules > /dev/null                               
sudo apt-get install -y raspi-gpio
sudo mkinitramfs -o /boot/initrd

sudo cat  <<"EOF" | sudo tee --append /boot/config.txt > /dev/null                               
initramfs initrd followkernel
ramfsfile=initrd
ramfsaddr=-1
EOF

sudo sed  -i -e '/rootwait/s/$/ root-ro-driver=overlay root-rw-pin=21/' /boot/cmdline.txt
