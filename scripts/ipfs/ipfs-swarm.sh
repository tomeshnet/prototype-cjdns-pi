#!/bin/bash
# shellcheck disable=SC2162
true

# Wait for ipfs to initalize
attempts=15
until [[ $(curl http://localhost:5001/api/v0/id -s 2>/dev/null) || ${attempts} -eq 0 ]]; do
    sleep 1
    attempts=$((attempts-1))
done

if [[  ${attempts} -eq 0 ]]; then
    exit 1
fi

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

# Add cjdns direct peers
while read -r cjdns_peer; do
    cjdns_addr=$(sudo /opt/cjdns/publictoip6 "$cjdns_peer")
    addPeer "${cjdns_addr}"

    # Add all that node's peers to the bottom of the list to check further hop peers
    # XXX: The below command hasn't been working -- so for now only 1-hop peers are checked
    #peers+=$(cjdnstool query getpeers $peer | sed -e '1d;$d' |awk -F. '{ print $6".k" }')

done <<< "$(sudo nodejs /opt/cjdns/tools/peerStats 2>/dev/null | awk '{ if ($3 == "ESTABLISHED") print $2 }' | awk -F. '{ print $6".k" }' | xargs)"

# Add yggdrasil direct peers
if [ "$(which yggdrasil)" ]; then
    while read -r ygg_peer; do
        addPeer "${ygg_peer}"
    done <<< "$(sudo yggdrasilctl getPeers | grep -v "(self)" | awk '{print $1}' | grep -v bytes_recvd | xargs)"
fi

# Update peers data since ipfs just started
sudo /usr/local/bin/nodeinfo-update.sh
