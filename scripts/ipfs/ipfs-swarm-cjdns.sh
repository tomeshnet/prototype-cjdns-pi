#!/bin/bash

# Wait for ipfs to initalize
attempts=15
until [[ $(curl http://localhost:5001/api/v0/id -q 2>/dev/null) || ${attempts} -eq 0 ]]; do
    sleep 1
    attempts=$((attempts-1))
done

if [[  ${attempts} -eq 0 ]]; then
    exit 1
fi

while read -r cjdns_peer; do
    cjdns_addr=$(sudo /opt/cjdns/publictoip6 $cjdns_peer)

    # See if they have ipfs announced
    res=$(curl http://[${cjdns_addr}]/nodeinfo.json)
    if [ ! -x "$res" ]; then
        id=$(echo ${res} | jq -r -M '.services.ipfs.ID')
        # Value is found
        if [[ ! ${id} == "null" ]] && [[ ! "${id}" == "" ]]; then
            # Connect ipfs to the peer
            ipfs swarm connect "/ip6/${cjdns_addr}/tcp/4001/ipfs/${id}"
            echo "Connecting to ${cjdns_addr}."
        fi
    fi

done <<< `sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($2 == "ESTABLISHED") print $1 }' | awk -F. '{ print $6".k" }' | xargs`

# Update peers data since ipfs just started
/usr/local/bin/nodeinfo-update.sh
