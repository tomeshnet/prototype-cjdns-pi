#!/bin/bash

echo -e "\n\n" >> /var/log/PeerDNS.log
cd /opt/PeerDNS
mix run --no-halt >> /var/log/PeerDNS.log 2>&1