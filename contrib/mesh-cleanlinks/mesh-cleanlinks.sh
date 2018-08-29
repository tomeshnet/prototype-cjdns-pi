#!/bin/bash
#script to remove poor quality links 
#usage: mesh-cleanlinks.sh <interface>
#requires gawk (apt-get install gawk)

limit="-65"

sudo iw dev $1 set mesh_param mesh_rssi_threshold $limit

cat << 'EOF' > /tmp/mesh.awk 
$1 == "Station" {
    MAC = $2
}
$1 == "signal" {
    wifi[MAC]["signal"] = $3
}
$1 == "mesh" && $2 == "plink:" {
    wifi[MAC]["status"] = $3
}
END {
    for (w in wifi) {
        printf "%s %s %s \n",w,wifi[w]["signal"],wifi[w]["status"]
    }
}
EOF

v=$(iw $1 station dump | awk -f /tmp/mesh.awk)
rm -f /tmp/mesh.awk

printf '%s\n' "$v" | while IFS= read -r line
do
    if [[ "$(echo $line | awk '{print $2'})" -lt "$limit" ]]; then
        if [[ "$(echo $line | awk '{print $3'})" == 'ESTAB' ]]; then
            mac="$(echo $line | awk '{print $1'})"
            sudo iw dev $1 station del $mac
            echo Deleting $mac (Signal to low)
        fi
    fi
done
