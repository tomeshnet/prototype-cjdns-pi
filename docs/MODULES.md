# Modules Documentation

A short summary of each module is directly below. Documentation for specific abilities of modules, or reference commands are further below.

## Table of Contents
- [Modules Documentation](#modules-documentation)
  - [Table of Contents](#table-of-contents)
  - [Command-line Variables](#command-line-variables)
  - [CJDNS](#cjdns)
    - [CJDNS Internet Peering](#cjdns-internet-peering)
  - [Yggdrasil](#yggdrasil)
  - [Yggdrasil subnetting](#yggdrasil-subnetting)
    - [Yggdrasil Internet Peering](#yggdrasil-internet-peering)
  - [Yggdrasil IPTunnel](#yggdrasil-iptunnel)
    - [Additional configuration](#additional-configuration)
      - [IPTunnel - Server](#iptunnel---server)
      - [IPTunnel - Client](#iptunnel---client)
        - [IPTunnel Client and Internet Peer](#iptunnel-client-and-internet-peer)
  - [IPFS](#ipfs)
  - [Firewall](#firewall)
    - [Applying changes](#applying-changes)
    - [IPv4](#ipv4)
      - [Change open ports](#change-open-ports)
    - [IPv6](#ipv6)
      - [Change open ports](#change-open-ports-1)
      - [Yggdrasil Clients](#yggdrasil-clients)
  - [Grafana](#grafana)
    - [Known install bugs](#known-install-bugs)
    - [Allow Anonymous access](#allow-anonymous-access)
  - [Prometheus](#prometheus)
  - [Secure Scuttlebutt](#secure-scuttlebutt)
    - [SSB Pub Peering](#ssb-pub-peering)

## Command-line Variables

| Feature Flag                    | HTTP Service Port                              | Description |
| :------------------------------ | :--------------------------------------------- | :---------- |
| `WITH_MESH_POINT`               | None                                           | Set to `true` if you have a suitable USB WiFi adapter and want to configure it as a 802.11s Mesh Point interface. |
| `WITH_AD_HOC`                   | None                                           | Set to `true` if you have a suitable USB WiFi adapter and want to configure it as a IBSS Ad-hoc interface. |
| `WITH_WIFI_AP`                  | None                                           | Set to `true` if you have a Raspberry Pi 3 and want to configure the on-board WiFi as an Access Point. The default configuration routes all traffic to the Ethernet port `eth0`. |
| `WITH_FIREWALL`                 | None                                           | Set to `true` if you want to enable a basic firewall on your node.|
| `WITH_CJDNS_IPTUNNEL`           | None                                           | Set to `true` if you want to use the cjdns iptunnel feature to set up an Internet gateway for your node. To configure as a server (exit Internet traffic for other nodes), create **/etc/cjdns.iptunnel.server** containing a newline-separated list of cjdns public keys of allowed clients. To configure as a client (use an exit server to access the Internet), create **/etc/cjdns.iptunnel.client** containing a newline-separated list of cjdns public keys of the gateway servers. You can only configure as one or the other, not both. |
| `WITH_IPFS`                     | **80**: HTTP-to-IPFS gateway at `/ipfs/HASH`   | Set to `true` if you want to install [IPFS](https://ipfs.io). |
| `WITH_IPFS_PI_STREAM`           | None                                           | Set to `true` if you want to install Pi stream service to live stream your camera over IPFS. Requires a Raspberry Pi with camera module. Player interface at `/video-player` *Warning: By default the camera will start broadcasting after first reboot.* |
| `WITH_SSB`                      |                                                | Set to `true` if you want to install [Scuttlebot (SSB)](https://github.com/ssbc/scuttlebot) a secure scuttlebutt daemon.  |
| `WITH_SSB_PATCHFOO`             | **80**: SSB web interface at `/patchfoo`       | Set to `true` if you want to install [Patchfoo](https://github.com/ssbc/patchfoo), allows you to interact with the scuttlebot backend with a web interface.  |
| `WITH_SSB_WEB_PI`                  | **80**: SSB web interface at `/ssb-web-pi`           | Set to `true` if you want to install [SSB Web Pi](https://github.com/darkdrgn2k/ssb-web-pi), interact with scuttlebot api via a web interface. **EXPERIMENTAL** |
| `WITH_PROMETHEUS_NODE_EXPORTER` | **9100**: Node Exporter UI                     | Set to `true` if you want to install [Prometheus Node Exporter](https://github.com/prometheus/node_exporter) to report network metrics. |
| `WITH_PROMETHEUS_SERVER`        | **9090**: Prometheus Server UI                 | Set to `true` if you want to install [Prometheus Server](https://github.com/prometheus/prometheus) to collect network metrics. *Requires Prometheus Node Exporter.* |
| `WITH_GRAFANA`                  | **3000**: Grafana UI (login: admin/admin)      | Set to `true` if you want to install [Grafana](https://grafana.com) to display network metrics. *Requires Prometheus Server.* |
| `WITH_H_DNS`                    | None                                           | Set to `true` if you want to use Hyperboria-compatible DNS servers: `fc4d:c8e5:9efe:9ac2:8e72:fcf7:6ce8:39dc`, `fc6e:691e:dfaa:b992:a10a:7b49:5a1a:5e09`, and `fc16:b44c:2bf9:467:8098:51c6:5849:7b4f` |
| `WITH_H_NTP`                    | None                                           | Set to `true` if you want to use a Hyperboria-compatible NTP server: `fc4d:c8e5:9efe:9ac2:8e72:fcf7:6ce8:39dc` |
| `WITH_EXTRA_TOOLS`              | None                                           | Set to `true` if you want to install non-essential tools useful for network analysis: vim socat oping bmon iperf3 |
| `WITH_WATCHDOG`                 | None                                           | Set to `true` if you want to enable hardware watchdog that will reset the device when the operating system becomes unresponsive. |
| `WITH_YRD`                      | None                                           | Set to `true` if you want to enable [yrd](https://github.com/kpcyrd/yrd), a helpful command-line tool for cjdns. |
| `WITH_YGGDRASIL`                | None                                           | Set to `true` if you want to install [Yggdrasil](https://yggdrasil-network.github.io/), an alternate and possibly more efficient mesh routing software than CJDNS. |
| `WITH_YGGDRASIL_IPTUNNEL`       | None                                           | Set to `true` if you want to use the yggdrasil iptunnel feature to set up an Internet gateway for your node. To configure as a server (exit Internet traffic for other nodes), create **/etc/yggdrasil.iptunnel.server** containing a newline-separated list of yggdrasil public keys of allowed clients and an ipaddress for that client. To configure as a client (use an exit server to access the Internet), create **/etc/yggdrasil.iptunnel.client** containing a newline-separated list of yggdrasil public keys of the gateway servers followed by the IP address set on the server. You can only configure as one or the other, not both and you can only have one entry on the client. |

To install all optional modules (not recommended), run the following command:

```
$ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/master/scripts/install && chmod +x install && WITH_MESH_POINT=true WITH_AD_HOC=false WITH_WIFI_AP=true WITH_FIREWALL=true WITH_CJDNS_IPTUNNEL=true WITH_IPFS=true WITH_SSB=true WITH_SSB_WEB_PI=true WITH_PROMETHEUS_NODE_EXPORTER=true WITH_PROMETHEUS_SERVER=true WITH_GRAFANA=true WITH_H_DNS=true WITH_H_NTP=true WITH_EXTRA_TOOLS=true WITH_WATCHDOG=true WITH_YRD=true ./install
```

## CJDNS
Cjdns (Caleb James DeLisle's Network Suite) is a networking protocol and reference implementation. It is founded on the ideology that networks should be easy to set up, protocols should scale smoothly, and security should be built in by default.

CJDNS uses cryptography to self-assign IPv6 address in the fc00::/8 subnet and will automatically peer with other nodes connected via Layer2 ethernet, broadcasts or configured UDP tunnels.

For more information please see the [CJDNS FAQ](https://github.com/cjdelisle/cjdns/blob/master/doc/faq/general.md).

To modify the ports that are accessable from CJDNS modify the `cjdns` *table* in the IPv6 firewall config file. See the [**Firewall**](#firewall) section for more details.

### CJDNS Internet Peering

Other peers can be found in the [this](https://github.com/hyperboria/peers) repo of peers. Try to connect to only a few peers, and ones that are close to where you live.

You'll see the peering information that will give you the address (ipv4 or ipv6) and credentials to connect to the node. You must either select to use just the ipv4 config, or you could use both. Now that we have this info, connect to your mesh device, and edit the following config file:

```
$ sudo nano /etc/cjdroute.conf
```

This file contains everything that is required for CJDNS to run, so be careful not to remove anything else, unless you know what you are doing. You need to head down to this line:

```
// Nodes to connect to (IPv4 only).
"connectTo":
{
```

This is where you input the ipv4 address. There is also a ipv6 field:

```
// Nodes to connect to (IPv6 only).
"connectTo":
{
```

Insert the respective code, and the save (ctrl+X to save, then ctrl+S to confirm file name, then ENTER to confirm changes).
your code should look somewhat like this:
```
// Nodes to connect to (IPv4 only).
"connectTo":
  {
                "123.123.123.123:54321": {
                  "peerName": "cosmetic-name.com",
                  "login": "peer-login",
                  "password": "peer-passwowrd-here",
                  "publicKey": "1234567890123456789012345678901234567890123456789012.k"
                }
  }
```

Next you should restart CJDNS with a `sudo systemctl restart cjdns` command. This will reload CJDNS with the new config file. Run a `status` command on your node, and make sure when it prints out
the text, that CJDNS is green with the text `[ACTIVE]`. if so, you have successfully connected to the remote peer, if it says `[INACTIVE]`, then there might be a typo in your config file. Make sure its formatted correctly (the config file is written using JSON).

## Yggdrasil

Yggdrasil is another piece of mesh routing software similar to CJDNS, but with potentially better performance and more active development. For more info visit the [website](https://yggdrasil-network.github.io).

## Yggdrasil subnetting

Yggdrasil will give each node (like your Pi, for example) an IPv6 address, but it can also give each node a subnet to distribute to its clients. This means that if you connect to the WiFi of your Pi, your device can get a unique Yggdrasil address, with all the benefits it provides. These include being able to access your device directly, without being NATed or blocked.

However, the Pi does have a firewall, so various commands need be run to allow access to clients. By default all Yggdrasil client access is blocked. See [**Firewall/IPv6/Yggdrasil Clients**](#yggdrasil-clients) to learn how to change that.

### Yggdrasil Internet Peering

Other peers can be found in the [public-peers](https://github.com/yggdrasil-network/public-peers) repo. Try to connect to only a few peers, and ones that are close to where you live.

Some will be IPv4, others IPv6. Head over to your mesh node yet again, and enter the following in your terminal:

```
$ sudo nano /etc/yggdrasil.conf
```

We are interested in this section of the config file:

```
// List of connection strings for static peers in URI format, e.g. tcp://a.b.c.d:e or socks://a.b.c.d:e/f.g.h.i:j.
Peers: []
```

This is where we are going to insert the code to connect to the peer node. Your code should look similar to this:

```
Peers: ["tcp://11.22.33.44:1234"]
```

Exit out of nano and save the changes. Restart Yggdrasil with a `sudo systemctl restart yggdrasil` command. Pass a `status` command to terminal and you should see green text where Yggdrasil is printed with the words `[ACTIVE]` present. You are now connected to the remote peer with Yggdrasil. If you see`[INACTIVE]`, then you need to check your code for typos, make sure there are qoute `""` around the whole entire address.  You may also need to wait a bit longer for the restart to complete.

## Yggdrasil IPTunnel

This module uses the [CKR](https://yggdrasil-network.github.io/2018/11/06/crypto-key-routing.html) function of yggdrasill to allow you to tunnel internet from an exit node (server) that has access to the internet to another node that does not. To do this you must exchange public keys.  The public key can be found in /etc/yggdrasil.conf

To use this module you must have it installed. You can check to see if the file `/usr/local/sbin/yggdrasil-setup` exists. If it does then you have it enable it during the protoype install.

### Additional configuration
Additional configurations can be made in the file `/etc/yggdrasil.iptunnel.conf`

Section `[iptunnel]`

**IPv6nat**
Disables masquerading of IPv6 tunnels. Set to `false` when routable addresses are being used across the tunnel. Usually when passing an additional subnet.

Default: *true*
Values: `true` , `false`

To add advertising of the subnet, add the following prefix to /etc/radvd.conf
```
   prefix 20xx:xxxx:xxxx:x::/64
    {
        AdvOnLink on;
        AdvAutonomous on;
    };
```

**SUBNET4**
*Server only*

Defines ip addresses to add to route table that will be routed over through yggdrasil. Must match ips in `yggdrasil.iptunnel.server`

Default: 10.10.0.0/24
Value: `Any ipv4 address range`

**SUBNET6**
*Server only*

Defines ipv6 addresses to add to route table that will be routed over through yggdrasil. Must match ips in `yggdrasil.iptunnel.server`

Default: fd00::/64
Value: `Any ipv6 address range`

**outint**
*Server Only*

Defines the interface connected to the internet.

Default: eth0
Value: `Any interface on the system`

**ipv6subnetint**
*Client Only*

Defines the interface that will pass on the IPv6 subnet.

Default: wlan-ap
Value: `Any interface on the system`


**yggint**
*Server Only*

Defines the yggdrasil interface.

Default: ygg0
Value: `Any interface on the system`

#### IPTunnel - Server

The IPTunnel server acts as a exit node. It will accept connections from other yggdrasil peeres listed in **/etc/yggdrasil.iptunnel.server** and form a tunnnel between them allowing the remote peer to access internet available on this node.

 To configure as a server (exit Internet traffic for other nodes),
 1. Create `/etc/yggdrasil.iptunnel.server`
 2. Fill it with newline-separated list of:
   - `EncryptionPublicKey` key of the clients (found in `/etc/yggdrasil.conf` on the client's device)
   - Single white space
   - IPv4 Address in the 10.10.0.0/24 range that will be assigned to the client
   - *optional* Single white space
   - *optional* IPv6 address in the fd00::/64 range that will be assigned to the client
   - *optional* Single white space
   - *optional* IPv6 subnet that will be routed through the client

Example
```
1234567890123456789012345678901234567890123456789012345678901234 10.10.0.1 fd00::1  
2345678901234567890123456789012345678901234567890123456789012345 10.10.0.2  
3456789012345678901234567890123456789012345678901234567890123467 10.10.0.3 fd00::3 fd00:1::/64  
```

**Note:** You do not have to assign an IPv6 address to all nodes, ones without an IPv6 address will simply not be issued one.

#### IPTunnel - Client

The IPTunnel client will establish a link to a server, and tunnel all traffic not currently in the routing table to this the server node. In most setups this means any traffic that is not for the local network you are directly connected to.

To configure as a client (use an exit server to access the Internet),
1. Create `/etc/yggdrasil.iptunnel.client`
1. Place a single line containing
   - `EncryptionPublicKey` of the server (found in `/etc/yggdrasil.conf` on the server's device)
   - Single white space
   - IPv4 Address assigned to you by the server
   - *optional* Single white space
   - *optional* IPv6 address assigned to you by the server
   - *optional* Single white space
   - *optional* IPv6 subnet that will be routed through the client

Example:
```
4567890123456789012345678901234567890123456789012345678901234567 10.10.0.4 fd00::4
```
or without IPv6

```
4567890123456789012345678901234567890123456789012345678901234567 10.10.0.4
```

or with IPv6 and subnet

```
4567890123456789012345678901234567890123456789012345678901234567 10.10.0.4 fd00::3 fd00:1::/64
```

##### IPTunnel Client and Internet Peer

If you wish to run an IPTunnel client on the same node as as an Internet peer, you will need to create a route to that node over the Internet connection available.

This must be done because since all Internet traffic will be redirected over the tunnel and a route is not created to the peer, Yggdrasil peering will try to route over the tunnel. Since the tunnel depends on the peer, the peer will not function, which will collapse the tunnel. In other words, the peer tries to feed packets over the tunnel, that tries to feed packets to the peer, causing both to fail.

Add the following command to your `/etc/rc.local`
```
route add 123.123.123/24 gw 192.168.0.1
```
Where:
`123.123.123` is the IP address of the Yggdrasil peer  
`192.168.0.1` is the current active gateway to the Internet, ie your router.


## IPFS
IPFS stands for Interplanetary File System. It is an open-source, peer-to-peer distributed hypermedia protocol that aims to function as a ubiquitous file system for all computing devices.

This module will install IPFS under the user where the script runs allowing you to access IPFS resouces both directly from the command line, and through the gateway available at <Pi IP Address>/ipfs/

## Firewall
The firewall module installes a basic firewall for your device. It will block all ports that were not meant to be open. By default there are no ports blocked from the Wireless Access Point interface (`wlan-ap`).

### Applying changes
After making any changes to files as outlined below, run `sudo systemctl restart hostapd` to apply the changes. This will take down the Pi's WiFi for a moment, but it will come back up on it's own. SSH sessions will freeze, but should reconnect on their own as well.

### IPv4
Default open ports to the device are below. Since both CJDNS and Yggdrasil use IPv6, these ports are open only for LAN or WiFi usage.

| Port | Protocol | Policy | Description               |
| :---- | :------ | :----- | :------------------------ |
| 67:68 | UDP     | Accept | DHCP Client/Server        |
| 22    | UDP     | Accept | SSH                       |
| 53    | TCP/UDP | Accept | DNS Server                |
| 80    | TCP     | Accept | HTTP                      |
| 443   | TCP     | Accept | SSH                       |
| 8008  | TCP/UDP | Accept | SSB                       |
| 9100  | TCP     | Accept | NodeExporter              |
| 9090  | TCP     | Accept | Prometheus Server         |
| 3000  | TCP     | Accept | Grafana                   |
| 5201  | TCP     | Accept | IPerf3                    |
| 4001  | TCP     | Accept | IPFS Swarm port           |

#### Change open ports

To change the open ports you can edit the IPv4 configuration file located at `/etc/iptables/rules.v4`

Remove or comment out (`#`) the lines of the ports that you wish to close and add new lines for additional ports you wish to open.

Likely you will not need to edit this file as much, if you are interested in opening mesh ports look at the **IPv6** section directly below.

These are standard `iptables` rules. The basic syntax is as follows:

`-A INPUT -j ACCEPT -p <protocol> --dport <port>`

`protocol` -  either `tcp` or `udp`, not required but recommended

`port` - Port you wish to open between 1-65535

### IPv6

Default open ports to the device over IPv6 are

| Port | Protocol | Policy | Description               |
| :---- | :------ | :----- | :------------------------ |
| 67:68 | UDP     | Accept | DHCP Client/Server        |
| 22    | UDP     | Accept | SSH                       |
| 53    | TCP/UDP | Accept | DNS Server                |
| 80    | TCP     | Accept | HTTP                      |
| 443   | TCP     | Accept | SSH                       |
| 5201  | TCP     | Accept | IPerf3                    |
| 4001  | TCP     | Accept | IPFS Swarm port           |
| 8008  | TCP/UDP | Accept | SSB                       |
| 9100  | TCP     | Accept | NodeExporter              |

#### Change open ports

To change the open ports you can edit the IPv6 configuration file located at `/etc/iptables/rules.v6`

Remove or comment out (#) the lines of the ports that you wish to close and add new lines for additional ports you wish to open.

These are standard `ip6tables` rules. The basic syntax is as follows:

`-A <table> -j ACCEPT -p <protocol> --dport <port>`

`table` - `CJDNS` or `YGGDRASIL` for opening the port to CJDNS or YGGDRASIL, `YGGCLIENT` for opening up access to [**Yggdrasil Clients**](#yggdrasil-clients), and `INPUT` to open the port up to all of IPv6.

`protocol` -  either `tcp` or `udp`, not required but recommended

`port` - Port you wish to open between 1-65535

Make sure to put your rules in the right section of the file, there are different ones depending on the table, with comments defining each section.

#### Yggdrasil Clients

Below are some different scenarios for opening up Yggdrasil clients. You will need to put these rules in `/etc/iptables/rules.v6`, in the Yggdrasil client rules section indicated by a comment.

 - **One client, one port**

Doing this is not recommended, as Yggdrasil clients IP addresses may change.

 - **All clients, one port**

`-A YGGCLIENT -j ACCEPT -p <PROTOCOL> --dport <PORT>`

Specifying a protocol is not required, but recommended.

- **All clients, all ports**

`-A YGGCLIENT -j ACCEPT`

If you use this rule, there is no point in having any other Yggdrasil client rules in the file.

You can specify a protocol, but that would limit the ports that are open.

## Grafana
**Note:** An older version is used for i386 deployment due to lack of official support in the newer version.

[Grafana](https://grafana.com/) is a dashboard used to display Prometheus collected data.  Once installed you can visit `http://<yournodeip>:3000`.  Default login is `admin`/`admin`. You can skip the welcome screen/wizard by clicking on the Grafana logo at the top left corner.

### Known install bugs

At times Grafana will not start up properly during install and the dashboards will not install.  To install them manually run the following commands from inside the `prototype-cjdns-pi/scripts/grafana` folder

```
BASE_DIR=`pwd`
curl --user admin:admin -X POST -H 'Content-Type: application/json' --data-binary "@$BASE_DIR/datasource.json" http://localhost:3000/api/datasources
curl --user admin:admin -X POST -H 'Content-Type: application/json' --data-binary "@$BASE_DIR/dashboard.json" http://localhost:3000/api/dashboards/db
```

### Allow Anonymous access

To allow read-one guest access without a password edit `/etc/grafana/grafana.ini`

Uncomment/Change settings as follows

```
[auth.anonymous]
# enable anonymous access
enabled = true
# specify organization name that should be used for unauthenticated users
org_name = Main Org.
# specify role for unauthenticated users
org_role = Viewer
```

## Prometheus
[Prometheus](https://prometheus.io/) is a monitoring system and time series database. 

**Note:** Prometheus Server does not support i386 installation because there is no known binary for it.

To make Prometheus dynamically change the nodes it will monitor during runtime, you can tell it to read from a file and update its targets every time the file is changed. Make the following change in `/opt/prometheus/prometheus.yml`.

Change this:
```
    static_configs:
    - targets: ['[fc0e:741f:1953:b0be:8958:2265:14cf:1e94]:9100']
```
to this:

```
    file_sd_configs:
        - files:
            - "/etc/prometheus.json"
```

Then create a `/etc/prometheus.json` file:

```
[
 {
  "targets": [
   "[fc0e:741f:1953:b0be:8958:2265:14cf:1e94]:9100",
   "[fc00:0000:0000:0000:0000:0000:0000:0000]:9100"
  ]
 }
]
```
Finally, restart the Prometheus service: Run `sudo systemctl restart prometheus-server`

If you wish to monitor multiple nodes, simply add more nodes to the JSON file. Remember the last entry does not have a `,`.

## Secure Scuttlebutt
[SSB](https://www.scuttlebutt.nz/) is a decent(ralised) secure gossip platform. It allows for the offline and decentralized distribution and copying of data in a "feeds" format. In practice it is often used as a social network similar to Facebook (but P2P), but has many other applications.

Our nodes can run a Scuttlebutt pub, which allows your messages to propagate through the mesh network, if your node is connected to one. You can download a [client](https://www.scuttlebutt.nz/applications) like [Patchwork](https://github.com/ssbc/patchwork), and if you installed the SSB module, you'll see the pub running on your Pi in the sidebar of the client when you connect to your node's WiFi network. This pub will sync with users of its network, and with mesh nodes nearby, spreading your messages and helping you get new ones.

### SSB Pub Peering

Beyond connecting with mesh peers, or peers on the LAN, you will need to connect to a "pub" to get your Scuttlebutt feed across the Internet. You can find a list of public pubs to join [here](https://github.com/ssbc/ssb-server/wiki/Pub-Servers).
