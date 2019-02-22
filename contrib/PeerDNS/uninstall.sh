#!/bin/bash

if [ "$(whoami)" == root ]; then
    echo -e "\033[1;36mDo not run this script as root. It will install things globally on its own."
    exit 1
fi

echo -e "\033[1;36mUninstalling Erlang..."
echo -e "\033[0;36m"
sudo dpkg -r esl-erlang
echo -e "\033[1;36mErlang uninstalled."

echo -e "\033[1;36mUninstalling Elixir..."
echo -e "\033[0;36m"
sudo rm -rf /opt/elixir
sudo sed -i 's/export PATH="\/opt\/elixir\/bin:$PATH"//' /etc/profile
echo -e "\033[1;36mElixir uninstalled."

echo -e "\033[1;36mUninstalling libsodium..."
echo -e "\033[0;36m"
sudo dpkg -r debian-archive-keyring
sudo apt remove libsodium23 libsodium-dev
sudo sed -i 's/deb http:\/\/ftp.ca.debian.org\/debian stretch-backports main//' /etc/apt/sources.list
sudo apt update
echo -e "\033[1;36mlibsodium from stretch-backports uninstalled."

echo -e "\033[1;36mUninstalling PeerDNS..."
echo -e "\033[0;36m"
# Remove all dnsmasq redirecting lines
sudo sed -i 's/address=\/.*\/127.0.0.1#5454//g' /etc/dnsmasq.conf
rm -rf "/opt/PeerDNS"
echo -e "\033[1;36mPeerDNS uninstalled."
echo -e "\033[1;36mRemember to remove any rules in /etc/iptables mentioning port 14123."
echo -e "\033[1;36mI would suggest running \033[0;36msudo apt autoremove\033[1;36mto remove dependencies."