#!/bin/sh

cp /opt/tomesh/nodeinfo.json /tmp

# Replace placeholders with dynamic info
sed -i -e "s/__REPO__/$(git remote get-url origin | awk -F / '{print $5}'| cut -d '.' -f1)/g" /tmp/nodeinfo.json
sed -i -e "s/__BRANCH__/$(git rev-parse --abbrev-ref HEAD)/g" /tmp/nodeinfo.json
sed -i -e "s/__COMMIT__/$(git rev-parse HEAD)/g" /tmp/nodeinfo.json
sed -i -e "s/__INSTALLED__/$(date)/g" /tmp/nodeinfo.json

sed -i -e "s/__KEY__/$(grep -m 1 '"ipv6"' /etc/cjdroute.conf | awk '{ print $2 }' | sed 's/[",]//g')/g" /tmp/nodeinfo.json
sed -i -e "s/__ORG__/$MESH_NAME/g" /tmp/nodeinfo.json

services=$(run-parts /opt/tomesh/nodeinfo.d/ | sed ':a $!{N; ba}; s/\n/\\n/g')
services=${services%,*}

sed -i -e "s/__SERVICES__/$services/g" /tmp/nodeinfo.json

cat  /tmp/nodeinfo.json | jq > /var/www/html/nodeinfo.json 
