#!/bin/bash

if [ "$(whoami)" == root ]; then
    echo "\033[1;36mDo not run this script as root. It will install things globally on its own."
    exit 1
fi

echo "\033[1;36mUninstalling Erlang..."
sudo dpkg -r esl-erlang
echo "\033[1;36mErlang uninstalled."

echo "\033[1;36mUninstalling Elixir..."
sudo rm -rf /opt/elixir
sudo sed -i 's/export PATH="\/opt\/elixir\/bin:$PATH"//' /etc/profile
echo "\033[1;36mElixir uninstalled."

echo "\033[1;36mUninstalling libsodium..."
sudo dpkg -r debian-archive-keyring
sudo apt remove libsodium23 libsodium-dev
sudo sed -i 's/deb http:\/\/ftp.ca.debian.org\/debian stretch-backports main//' /etc/apt/sources.list
sudo apt update
echo "\033[1;36mlibsodium from stretch-backports uninstalled."

echo "\033[1;36mUninstalling PeerDNS..."
# Remove all dnsmasq redirecting lines
sudo sed -i 's/address=\/.*\/127.0.0.1#5454//g' /etc/dnsmasq.conf
rm -rf "/opt/PeerDNS"
echo "\033[1;36mPeerDNS uninstalled."
echo "\033[1;36mRemember to remove any rules in /etc/iptables mentioning port 14123."