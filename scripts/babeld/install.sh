#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#Enable test repo
echo deb deb http://meshwithme.online/deb/repos/apt/debian stretch main | sudo tee /etc/apt/sources.list.d/tomesh.list

sudo apt-get update
sudo apt-get install babeld

# Dont announce yggdrasil of cjdns addresses
sudo systemctl stop babled
echo redistribute deny local ip 200::/7 | sudo tee --append /etc/babeld.conf
echo redistribute deny local ip 300::/7 | sudo tee --append /etc/babeld.conf
echo redistribute deny local ip fc00::/8 | sudo tee --append /etc/babeld.conf
sudo systemctl start babled
