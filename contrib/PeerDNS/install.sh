#!/bin/bash

set -e

ERLANG_VERSION=20.1.7
ELIXIR_VERSION=1.8.1

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(whoami)" == root ]; then
    echo "\033[1;36mDo not run this script as root. It will install things globally on its own."
    exit 1
fi

cd /tmp
echo "\033[1;36mInstalling Erlang $ERLANG_VERSION ..."
wget "https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_$ERLANG_VERSION-1~raspbian~stretch_armhf.deb"
sudo dpkg -i "esl-erlang_$ERLANG_VERSION-1~raspbian~stretch_armhf.deb"
echo "\033[1;36mErlang installed."

echo "\033[1;36mInstalling Elixir $ELIXIR_VERSION ..."
sudo rm -rf /opt/elixir || true  # Remove it for updates
sudo mkdir /opt/elixir || true
sudo chmod -R 755 /opt/elixir  # Everyone can read and execute - only root can write
sudo wget -P /opt/elixir "https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip"
sudo unzip /opt/elixir/Precompiled.zip -d /opt/elixir
sudo rm /opt/elixir/Precompiled.zip
echo 'export PATH="/opt/elixir/bin:$PATH"' | sudo tee -a /etc/profile  # Add to elixir binaries to PATH
echo "\033[1;36mElixir installed."

echo "\033[1;36mInstalling libsodium from stretch-backports..."
# Debian keys needed for stretch-backports to be enabled, but Raspbian won't let you download them through apt
wget -P /tmp http://ftp.ca.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2017.5_all.deb
sudo dpkg -i /tmp/debian-archive-keyring_2017.5_all.deb
echo "deb http://ftp.ca.debian.org/debian stretch-backports main" | sudo tee -a /etc/apt/sources.list
sudo apt update -y
sudo apt install -y -t stretch-backports libsodium23 libsodium-dev
echo "\033[1;36mlibsodium installed."

echo "\033[1;36mInstalling PeerDNS in /home/$(whoami) ..."
cd "/home/$(whoami)"
git clone https://github.com/p2pstuff/PeerDNS.git
cd PeerDNS
# XXX: Do automatic installs that come up
mix deps.get
# Setup serving the webUI locally
cd ui
npm install
npm run build
cd ..
# Copy over config file
cp "$BASE_DIR/config.exs" config/
# Setup dnsmasq to resolve those tlds
echo "address=/p2p/127.0.0.1#5454" | sudo tee -a /etc/dnsmasq.conf
echo "address=/mesh/127.0.0.1#5454" | sudo tee -a /etc/dnsmasq.conf
echo "address=/h/127.0.0.1#5454" | sudo tee -a /etc/dnsmasq.conf
echo "address=/hype/127.0.0.1#5454" | sudo tee -a /etc/dnsmasq.conf
echo "address=/y/127.0.0.1#5454" | sudo tee -a /etc/dnsmasq.conf
echo "address=/ygg/127.0.0.1#5454" | sudo tee -a /etc/dnsmasq.conf
echo "address=/tomesh/127.0.0.1#5454" | sudo tee -a /etc/dnsmasq.conf

sudo iptables -A INPUT -j ACCEPT -p tcp --dport 14123
sudo iptables -A INPUT -j ACCEPT -p udp --dport 14123
sudo ip6tables -A INPUT -j ACCEPT -p tcp --dport 14123
sudo ip6tables -A INPUT -j ACCEPT -p udp --dport 14123

echo "\033[1;36mPeerDNS installed and set up."
echo "\033[1;36mThe firewall has been opened temporarily. To keep the required ports open, add these lines to /etc/iptables/rules.v4 and /etc/iptables/rules.v6, in the raw INPUT rules section."
echo "\033[0;36m    -A INPUT -j ACCEPT -p tcp --dport 14123"
echo "\033[0;36m    -A INPUT -j ACCEPT -p udp --dport 14123"
echo ""
echo "\033[1;36mGo to ~/PeerDNS and run \033[0;36mmix run --no-halt\033[1;36m to start PeerDNS."
echo "\033[1;36mRun \033[0;36mmix run --no-halt 2>&1 /dev/null\033[1;36m to start it without any output."
echo "\033[1;36m CJDNS peers will automatically be peered with."
echo "\033[1;36mAdd Yggdrasil peers by running the ygg-peer.sh script in this folder."
echo "\033[1;36mNavigate to this device at port 14123 in your browser for a web UI to add domain records."