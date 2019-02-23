#!/bin/bash

# TODO: Switch to using temporary list once it gets developed

if [ "$(which yggdrasil)" ]; then
    read -a peers  <<< "$(sudo yggdrasilctl getPeers | grep -v "(self)" | awk '{print $1}' | grep -v bytes_recvd | xargs)"
    for peer in "${peers[@]}"; do
        curl localhost:14123/api/privileged/trustlist -d '{"action":"add","ip":"'"$peer"'","name":"Ygg peer added by ygg-peer.sh","api_port":14123,"weight":0.5}' -v -H "Content-Type: application/json"
    done
fi

echo "\033[1;36mReminder: You will stay peered through PeerDNS to these peers, even when they are not local peers anymore, because this script does not remove them. You must do it manually yourself, or restart the daemon."