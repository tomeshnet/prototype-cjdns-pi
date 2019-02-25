#!/bin/bash

if [ "$(which yggdrasil)" ]; then
    # Get rid of old peers
    curl localhost:14123/api/privileged/peer_list/yggdrasil -X POST -H "Content-Type: application/json" -d '{"action": "clear_all"}'
    read -a peers  <<< "$(sudo yggdrasilctl getPeers | grep -v "(self)" | awk '{print $1}' | grep -v bytes_recvd | xargs)"
    for peer in "${peers[@]}"; do
        curl localhost:14123/api/privileged/peer_list/yggdrasil -X POST -H "Content-Type: application/json" -d '{"action":"add","ip":"'"$peer"'","name":"Yggdrasil peer '"${peer: -4}"'","api_port":14123,"weight":0.5}'
    done
fi

echo "\033[1;36mRun this script whenever your peers change.\033[0m"