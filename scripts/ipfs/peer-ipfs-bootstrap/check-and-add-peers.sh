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

        # Were there any peers that were previously saved, but obviously now no longer work?
        if ! [[ $(cat /var/lib/peer-ipfs-boostrap/peers.data | wc -l) -eq 0 || ( $(cat /var/lib/peer-ipfs-boostrap/peers.data | wc -l) -gt 0 && $(head -c 5 /var/lib/peer-ipfs-bootstrap/peers.data) = /ip6/ ) ]]; then
            read -a prev_peers <<< `cat /var/lib/peer-ipfs-bootstrap/peers.data | xargs`
            for peer in "${prev_peers[@]}"; do
                address=$(echo ${peer} | awk -F / '{ print $(NF-4) }')

                # Check if it's online
                if ping -c 5 $address; then

                    # It's online, check to see if IPFS is enabled
                    res=$(curl ${address}/nodeinfo.json)
                    if [[ echo ${res} | jq -r '.services | contains(["ipfs"])' ]]; then

                        # IPFS is enabled, but bootstrapping still failed
                        # Either nodeinfo is lying, or IPFS is temporarily down at the moment for this node
                        # The second is assumed and so the peer is not removed from the bootstrap list
                        continue
                    else

                        # IPFS has been removed from nodeinfo manually. It is assumed the peer will never be a candidate for bootstrapping again
                        # The peer is removed
                        ipfs bootstrap rm $peer
                        sed -i "/$peer/d" /var/lib/peer-ipfs-bootstrap/peers.data
                    fi
                else

                    # It's not online. The peer is removed, since this script does not track long term uptime stats of nodes.
                    ipfs bootstrap rm $peer
                    sed -i "/$peer/d" /var/lib/peer-ipfs-bootstrap/peers.data
                fi

            done
        fi

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
                        echo "/ip6/${peer}/tcp/4001/ipfs/${id}" >> /var/lib/peer-ipfs-bootstrap/peers.data
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
