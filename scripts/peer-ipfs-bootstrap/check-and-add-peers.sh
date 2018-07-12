#!/bin/bash

ipfs_peers=$(ipfs swarm peers | wc -l)

# The amount of bootstrap peers to find
MAX_PEERS=4

# Wait for peers to be gathered
sleep 10

# Checking that there aren't any IPFS peers
if [[ -z ${ipfs_peers} || ${ipfs_peers} -lt 2 ]]; then
        # Get cjdns peers to query them
        new_peers=0
        read -a peers <<< `sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($2 == "ESTABLISHED") print $1 }' | awk -F. '{ print $6".k" }' | xargs`
        
        until [[ ${new_peers} -eq ${MAX_PEERS} ]] ; do
                peer=$(sudo /opt/cjdns/publictoip6 $peer)
                
                # See if they have IPFS enabled
                res=$(curl ${peer}/info/ipfs)
                if [[ ${res} = *"ID"* ]]; then
                        id=$(echo ${res} | jq .ID)
                                
                        # Add them as a bootstrap peer 
                        ipfs bootstrap add "/ip6/${peer}/tcp/4001/ipfs/${id}"
                        new_peers=$((new_peers + 1))
                fi

                # Removed them but add all their peers to the bottom of the list
                peers=("${peers[@]/$peer}")

                # XXX: The below command hasn't been working
                peers+=$(cjdnstool query getpeers $peer | awk -F. '{ print $6".k" }')
        done

        sudo systemctl restart ipfs
fi
