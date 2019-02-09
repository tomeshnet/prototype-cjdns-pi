#!/bin/bash

# This script connects to local mesh peers,
# and it sets up connection filters based on what networks this node can access.
# It runs continually, to change IPFS settings as the environment around the node changes.


# Wait for IPFS to initalize
attempts=15
until [[ $(curl http://localhost:5001/api/v0/id -s 2>/dev/null) || ${attempts} -eq 0 ]]; do
    sleep 1
    attempts=$((attempts-1))
done

if [[  ${attempts} -eq 0 ]]; then
    echo "Error: Failed to connect to local IPFS daemon. Is it running?"
    exit 1
fi

# Update peers's data since IPFS just started
echo "Updating nodeinfo..."
sudo /usr/local/bin/nodeinfo-update.sh

function addPeer  {
    addr=$1
    # See if they have IPFS enabled
    res=$(curl http://["${addr}"]/nodeinfo.json -s)
    if [ ! -x "${res}" ]; then
        id=$(echo "${res}" | jq -r -M '.services.ipfs.ID')
        # Value is found
        if [[ ! ${id} == "null" ]] && [[ ! "${id}" == "" ]]; then
            # Connect to neighbouring IPFS nodes
            # Check for QUIC connections first
            if [ "$(echo "${res}" | jq -r -M '.services.IPFS.quic_enabled')" == 'true' ]; then
                ipfs swarm connect "/ip6/${addr}/udp/4001/quic"
            else
                ipfs swarm connect "/ip6/${addr}/tcp/4001/ipfs/${id}"
            fi
            echo "Connecting to ${addr}"
        fi
    fi
}

# Continually mesh with peers and add or remove filter rules as networks go up and down
while true; do
    # Check if CJDNS is running
    if [ "$(systemctl status cjdns.service | grep 'Active: ' | awk '{ print $2 }')" = 'active' ]; then
        # Connect with direct peers over IPFS
        while read -r cjdns_peer; do
            cjdns_addr=$(sudo /opt/cjdns/publictoip6 "$cjdns_peer")
            addPeer "${cjdns_addr}"

            # Add all that node's peers to the bottom of the list to check further hop peers
            # XXX: The below command hasn't been working -- so for now only 1-hop peers are checked
            #peers+=$(cjdnstool query getpeers $peer | sed -e '1d;$d' |awk -F. '{ print $6".k" }')

        done <<< "$(sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($3 == "ESTABLISHED") print $2 }' | awk -F. '{ print $6".k" }' | xargs)"

        # Remove a filter if there was one
        ipfs swarm filters rm '/ip6/fc00::/ipcidr/8'
    else
        ipfs swarm filters add '/ip6/fc00::/ipcidr/8'
        echo "Blocked CJDNS network"
    fi

    if [ "$(systemctl status yggdrasil.service | grep 'Active: ' | awk '{ print $2 }')" = 'active' ]; then
        while read -r ygg_peer; do
            addPeer "${ygg_peer}"
        done <<< "$(sudo yggdrasilctl getPeers | grep -v "(self)" | awk '{print $1}' | grep -v bytes_recvd | xargs)"

        ipfs swarm filters rm '/ip6/0200::/ipcidr/7'
    else
        ipfs swarm filters add '/ip6/0200::/ipcidr/7'
        echo "Blocked Yggdrasil network"
    fi

    # Clearnet or regular Internet IPv4 access
    if ! ping -w 2 1.1.1.1 &>/dev/null; then
        # Block all IPv4 - it's not used anywhere else
        ipfs swarm filters add '/ip4/0.0.0.0/ipcidr/0'
        echo "Blocked all of IPv4"
    else
        ipfs swarm filters rm '/ip4/0.0.0.0/ipcidr/0'
    fi

    # Clearnet IPv6 access
    if ! ping -w 2 2606:4700:4700::1111 &>/dev/null; then  # IPv6 version of 1.1.1.1 above
        # Block global unicast for IPv6
        ipfs swarm filters add '/ip6/2000::/ipcidr/3'
        echo "Blocked IPv6 internet"
    else
        ipfs swarm filters rm '/ip6/2000::/ipcidr/3'
    fi

done