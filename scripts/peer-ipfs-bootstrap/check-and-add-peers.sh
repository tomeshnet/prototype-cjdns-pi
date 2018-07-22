#!/bin/bash


# The amount of bootstrap peers to find
MAX_PEERS=4

# Wait for peers to be gathered
echo "Waiting 10 seconds for IPFS to bootstrap..."
sleep 10
echo "Done."

ipfs_peers=$(ipfs swarm peers | wc -l)

# Checking that there aren't any IPFS peers
if [[ -z ${ipfs_peers} || ${ipfs_peers} -eq 0 ]]; then
        echo "No IPFS peers were found, looking for them now."

        # Get 1-hop cjdns peers to query them
        new_peers=0
        read -a peers <<< `sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($2 == "ESTABLISHED") print $1 }' | awk -F. '{ print $6".k" }' | xargs`
        
        until [[ ${new_peers} -eq ${MAX_PEERS} || ${#peers[@]} -eq 0 ]]; do
                
                # Reset the list to the next top unchecked peer
                peer=${peers[0]}
                peer=$(sudo /opt/cjdns/publictoip6 $peer)
                
                # See if they have IPFS enabled
                res=$(curl ${peer}/nodeinfo.json)
                if [[ echo ${res} | jq -r '.services | contains(["ipfs"])' ]]; then
                        id=$(echo ${res} | jq -r '.services.ipfs.ID')
                                
                        # Add them as a bootstrap peer 
                        ipfs bootstrap add "/ip6/${peer}/tcp/4001/ipfs/${id}"
                        new_peers=$((new_peers + 1))
                        echo "Added cjdns peer ${peer} as a bootstrap node for IPFS."
                fi

                # Remove them
                peers=("${peers[@]/$peer}")
                
                # Add all that node's peers to the bottom of the list to check further hop peers
                # XXX: The below command hasn't been working -- so for now only 1-hop peers are checked
                #peers+=$(cjdnstool query getpeers $peer | sed -e '1d;$d' |awk -F. '{ print $6".k" }')
        
        done
        echo "Restarting ipfs.service..."
        sudo systemctl restart ipfs
        echo "Restarted."
fi
