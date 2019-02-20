#!/bin/bash

# TODO: Remove old peers

if [ "$(which yggdrasil)" ]; then
            YGG_IP=$(yggdrasilctl getself | grep address | awk '{print $3}')
            read -a peers  <<< "$(sudo yggdrasilctl getPeers | grep -v "(self)" | awk '{print $1}' | grep -v bytes_recvd | xargs)"
            for peer in "${peers[@]}"; do
                curl localhost:14123/api/privileged/trustlist -d '{"action":"add","ip":"'"$peer"'","name":"Ygg peer added by ygg-peer.sh","api_port":14123,"weight":0.5}' -v -H "Content-Type: application/json"
            done
        fi


