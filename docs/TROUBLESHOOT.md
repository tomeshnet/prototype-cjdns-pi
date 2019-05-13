# Wireless Meshing

Below are a few things you should look at when diagnosing connections. These can help identify bad configurations or other errors.

## IBSS
- `iw dev` - do all the devices have matching BSSID and Channels
- `iw wlan0 station dump` does it show stations
    - If they do then the peering between nodes is working
    - If they do not show up, this may just mean the drive does not report properly. For example the onboard pi driver will not yield any results
- `sudo /usr/bin/mesh-adhoc`  - does it return any errors
   - If yes run `sudo bash -x  /usr/bin/mesh-adhoc` - Thiw will help identify where the error occurs
- If you set an IP address on wlan0 on both sides, can it ping in the clear
    - On Pi-1 run `ifconfig wlan0 10.10.10.1/24`
    - On pi two run `ifconfig wlan0 10.10.10.2/24`
    - On Pi-1 run `ping 10.10.10.1`
    - On Pi-2 run `ping 10.10.10.2`
    - Does it say `request timeout` or does the ping succeed?

## Mesh Point
- `iw dev` - do all the devices have matching BSSID and Channels
- `cat /usr/bin/mesh-mesh` - does the JOIN line have the correct mesh name
- `iw wlan0 station dump` - does it show the stations
- `sudo /usr/bin/mesh-point`  - does it return any errors
   - If es run `sudo bash -x  /usr/bin/mesh-point` -  - This will help identify where the error occurs
- If you set an IP address on wlan0 on both sides, can it ping in the clear
    - On Pi-1 run `ifconfig wlan0 10.10.10.1/24`
    - On Pi-2 run `ifconfig wlan0 10.10.10.2/24`
    - On Pi-1 run `ping 10.10.10.1`
    - On Pi-2 run `ping 10.10.10.2`
    - Does it say `request timeout` or does the ping succeed?

# IPTunnel - Internet Exit Over Yggdrasil/CJDNS
- Can client node ping cjdns/yggdsaill address of exit node
- Can exit node access the internet
- Can client node ping an ip address (not DNS)
    - IE: `ping 1.1.1.1`

## IPTUNNEL - cjdns
- Is IPTunnel installed (`/usr/local/sbin/cjdns-setup` exists)
- Is the cjdns.iptunnel.server/client filename correct and on the correct device
- Are the keys correct (ends in a k)
- Does `tun0` have a ipv4 ipaddress on server
- Does `tun0` have ipv4 address on client
- Can you ping the ipv4 addresses across the tunnel
- Does masquerade line in `iptables -L -v -n -t nat` exist
- Does masquerade line in `iptables -L -v -n -t nat` show the right out interface

## IPTUNNEL - yggdrasil
- Is iptunnel installed (/usr/local/sbin/yggdrasil-setup exists)
- Is the yggdrasil.iptunnel.server/client filename correct and on the correct device
- Are the keys correct (64 character alpha numeric)
- Does `ygg0` have IPv4 address on client
- Can you ping the IPv4 addresses from the server
- Does MASQUERADE line in `iptables -L -v -n -t nat` exist
- Does masquerade line in `iptables -L -v -n -t nat` show the right out interface
