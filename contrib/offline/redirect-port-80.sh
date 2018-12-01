#!/bin/sh

# Backup file
if ! [ -f "/etc/hostapd/nat.sh.bak" ]; then
  sudo cp /etc/hostapd/nat.sh /etc/hostapd/nat.sh.bak
fi

# Redirect all IPv4 80 traffic to the pi
echo iptables -t nat -I PREROUTING -i wlan-ap -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1:80 | sudo tee --append  /etc/hostapd/nat.sh > /dev/null 

# Prevent masquerading out IPv4
# This is to prevent IPTUNNEL and routing to the internet (Exit node)
sudo sed -i "/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE/d" /etc/hostapd/nat.sh 

# Set nginx to redirect any 404 errors to /
sed -i '$i    error_page 404 =200 /index.html;' /etc/nginx/sites-enabled/main.conf
sudo systemctl restart hostapd
