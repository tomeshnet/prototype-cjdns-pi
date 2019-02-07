#!/bin/bash

# This script sets up IPFS.
# It connects to local mesh peers,
# and it sets up connection filters based on what networks this node can access.


# Wait for IPFS to initalize
attempts=15
until [[ $(curl http://localhost:5001/api/v0/id -s 2>/dev/null) || ${attempts} -eq 0 ]]; do
    sleep 1
    attempts=$((attempts-1))
done

if [[  ${attempts} -eq 0 ]]; then
    exit 1
fi

#################################
# Connect to local mesh peers
#################################
function addPeer  {
    addr=$1
    # See if they have IPFS enabled
    res=$(curl http://["${addr}"]/nodeinfo.json -s)
    if [ ! -x "${res}" ]; then
        id=$(echo "${res}" | jq -r -M '.services.ipfs.ID')
        # Value is found
        if [[ ! ${id} == "null" ]] && [[ ! "${id}" == "" ]]; then
            # Connect to neighbouring ipfs
            ipfs swarm connect "/ip6/${addr}/tcp/4001/ipfs/${id}"
            echo "Connecting to ${addr}"
        fi
    fi
}

# Add CJDNS direct peers if the service is running
if [ "$(systemctl status cjdns.service | grep 'Active: ' | awk '{ print $2 }')" = 'active' ]; then
    while read -r cjdns_peer; do
        cjdns_addr=$(sudo /opt/cjdns/publictoip6 "$cjdns_peer")
        addPeer "${cjdns_addr}"

        # Add all that node's peers to the bottom of the list to check further hop peers
        # XXX: The below command hasn't been working -- so for now only 1-hop peers are checked
        #peers+=$(cjdnstool query getpeers $peer | sed -e '1d;$d' |awk -F. '{ print $6".k" }')

    done <<< "$(sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($3 == "ESTABLISHED") print $2 }' | awk -F. '{ print $6".k" }' | xargs)"
fi

# Add Yggdrasil direct peers if the service is running
if [ "$(systemctl status yggdrasil.service | grep 'Active: ' | awk '{ print $2 }')" = 'active' ]; then
    while read -r ygg_peer; do
        addPeer "${ygg_peer}"
    done <<< "$(sudo yggdrasilctl getPeers | grep -v "(self)" | awk '{print $1}' | grep -v bytes_recvd | xargs)"
fi

#################################
# Setup connection filter rules
#################################

# Remove previous ones first, just in case
ipfs swarm filters rm '/ip6/fc00::/ipcidr/8'
ipfs swarm filters rm '/ip6/0200::/ipcidr/7'
ipfs swarm filters rm '/ip4/0.0.0.0/ipcidr/0'

# If CJDNS isn't running...
if ! [ "$(systemctl status cjdns.service | grep 'Active: ' | awk '{ print $2 }')" = 'active' ]; then
    # Block connecting to CJDNS nodes
    ipfs swarm filters add '/ip6/fc00::/ipcidr/8'
fi
# Yggdrasil
if ! [ "$(systemctl status yggdrasil.service | grep 'Active: ' | awk '{ print $2 }')" = 'active' ]; then
    ipfs swarm filters add '/ip6/0200::/ipcidr/7'
fi
# Clearnet or regular Internet
if ! ping -c 3 1.1.1.1 &> /dev/null; then
    # Right now it blocks ALL IPv4
    # XXX: This is not a permanent solution
    ipfs swarm filters add '/ip4/0.0.0.0/ipcidr/0'
fi