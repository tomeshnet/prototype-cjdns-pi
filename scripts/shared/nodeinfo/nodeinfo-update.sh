#!/bin/sh

cp /opt/tomesh/nodeinfo.json /tmp

# Replace placeholders with dynamic info
sed -i -e "s/__KEY__/$(grep -m 1 '"ipv6"' /etc/cjdroute.conf | awk '{ print $2 }' | sed 's/[",]//g')/g" /tmp/nodeinfo.json

services=$(run-parts /opt/tomesh/nodeinfo.d/ | sed ':a $!{N; ba}; s/\n/\\n/g')
services=${services%,*}

sed -i -e "s|__SERVICES__|$services|g" /tmp/nodeinfo.json

jq . /tmp/nodeinfo.json  | sudo tee /var/www/html/nodeinfo.json > /dev/null
