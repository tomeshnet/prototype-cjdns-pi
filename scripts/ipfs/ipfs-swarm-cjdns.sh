#!/bin/bash

# Wait for ipfs to initalize
attempts=15
until [[ $( curl http://localhost:5001/api/v0/id -q 2>/dev/null) || ${attempts} -eq 0 ]]; do
    sleep 1
    attempts=$((attempts-1))
done

while read -r peer; do
    peer=$(sudo /opt/cjdns/publictoip6 $peer)

    # See if they have IPFS enabled
    res=$(curl http://[${peer}]/nodeinfo.json)
    if [ ! -x "$res" ]; then        
        id=$(echo ${res} | jq -r -M '.services.ipfs.ID')
        # Value is found
        if [[ ! ${id} == "null" ]] && [[ ! "${id}" == "" ]]; then
            # Add them as a bootstrap peer
            ipfs swarm connect "/ip6/${peer}/tcp/4001/ipfs/${id}"
            echo "Connecting to ${peer}."
        fi
    fi

    # Add all that node's peers to the bottom of the list to check further hop peers
    # XXX: The below command hasn't been working -- so for now only 1-hop peers are checked
    #peers+=$(cjdnstool query getpeers $peer | sed -e '1d;$d' |awk -F. '{ print $6".k" }')

done <<< `sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($2 == "ESTABLISHED") print $1 }' | awk -F. '{ print $6".k" }' | xargs`

# update peers data since ipfs just started 
/usr/local/bin/nodeinfo-update.sh
