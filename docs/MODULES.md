# Modules Documentation

A short summary of each module is directly below. Documentation for specific abilities of modules, or reference commands are further below.

## Command-line flags

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

## Yggdrasil
Yggdrasil is another piece of mesh routing software similar to CJDNS, but with potentially better performance and more active development. For more info visit the [website](https://yggdrasil-network.github.io).

### Yggdrasil subnetting

Yggdrasil will give each node (like your Pi, for example) an IPv6 address, but it can also give each node a subnet to distribute to its clients. This means that if you connect to the WiFi of your Pi, your device can get a unique Yggdrasil address, with all the benefits it provides. These include being able to access your device directly, without being NATed or blocked.

However, the Pi does have a firewall, so various commands need be run to allow access to clients. By default all Yggdrasil client access is blocked. See [**Firewall/IPv6/Yggdrasil Clients**](#yggdrasil-clients) to learn how to change that.

### Yggdrasil IPTunnel

This module will allow you to tunnel internet from an EXIT node (server) that has Internet to another node that does not. To do this you must exchange public keys.  The public key can be found in /etc/yggdrasil.conf

#### Server
 To configure as a server (exit Internet traffic for other nodes), 
 1. create **/etc/yggdrasil.iptunnel.server**
 1. fill it with newline-separated list of:
   - EncryptionPublicKey key of the clients
   - single white space
   - IP Address in the 10.10.0.0/24 range that will be assigned to the client

Example
```
1234567890123456789012345678901234567890123456789012345678901234 10.10.0.1
2345678901234567890123456789012345678901234567890123456789012345 10.10.0.2
3456789012345678901234567890123456789012345678901234567890123467 10.10.0.3
```

#### Client
To configure as a client (use an exit server to access the Internet), 
1. create **/etc/yggdrasil.iptunnel.client** 
1. place a single line containing
   - EncryptionPublicKey of the server
   - single space
   - IP Address assigned to you by the server

Example
```
4567890123456789012345678901234567890123456789012345678901234567 10.10.0.4
```

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

## Adding deprecated.systems peer info into CJDNS and Yggdrasil (Optional)

#### CJDNS

Go to [Deprecated Systems](https://deprecated.systems/) website. You will see the following information:

```
cjdns peering

    "159.203.5.91:30664": {
      "peerName": "deprecated.systems",
      "login": "tomesh-public",
      "password": "iuw4nklm3j89qno876ef2jabpvlg1j0",
      "publicKey": "2scyvybg4qqms1c5c9nyt50b1cdscxnr6ycpwsxf6pccbmwuynk0.k"
    }

    "[2604:a880:cad:d0::45:d001]:30664": {
      "peerName": "deprecated.systems",
      "login": "tomesh-public",
      "password": "iuw4nklm3j89qno876ef2jabpvlg1j0",
      "publicKey": "2scyvybg4qqms1c5c9nyt50b1cdscxnr6ycpwsxf6pccbmwuynk0.k"
    }
```

This is the peering information that will give you the address (ipv4 or ipv6) and credentials to connect to 
the node. You must either select to use just the ipv4 config, or you could use both. Now that we have this info, 
connect to your mesh device, and edit the following config file:

```
$ sudo nano /etc/cjdroute.conf
```

This file contains everything that is required for cjdns to run, so be careful not to remove anything else, unless
you know what you are doing. You need to head down to this line:

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
                               "159.203.5.91:30664": {
                                 "peerName": "deprecated.systems",
                                 "login": "tomesh-public",
                                 "password": "iuw4nklm3j89qno876ef2jabpvlg1j0",
                                 "publicKey": "2scyvybg4qqms1c5c9nyt50b1cdscxnr6ycpwsxf6pccbmwuynk0.k"
                               }
                 }
```

Next you should restart cjdns with a `sudo systemctl restart cjdns` command. This will reload cjdns
with the new config file. Run a `status` command on your node, and make sure when it prints out
the text, that cjdns is green with the text `[ACTIVE]`. if so, you have successfully connected to the remote peer,
if it says `[INACTIVE]`, then there might be a typo in your config file. Make sure its formatted correctly (the
config file is written using JSON).

### Yggdrasil

To connect to the "Deprecated Systems" node via Yggdrasil, you must do the similar as above, but with quite a few less steps.

On the [deprecated.systems](https://deprecated.systems/) website, there is a section outlining the info for Yggdrasil:

```
"104.248.104.141:59168"
"[2604:a880:cad:d0::45:d001]:59168"
```

One is ipv4, the other ipv6. Head over to your mesh node yet again, and enter the following in your terminal:

```
$ sudo nano /etc/yggdrasil.conf
```

We are interested in this section of the config file:

```
List of connection strings for static peers in URI format, e.g. tcp://a.b.c.d:e or socks://a.b.c.d:e/f.g.h.i:j.
Peers: []
```

This is where we are going to insert the code to connect to the peer node. Your code should look similar to this:

```
Peers: ["tcp://104.248.104.141:59168"]
```

Exit out of nano and save the changes. Restart Yggdrasil with a `sudo killall yggdrasil` command. Pass a `status`
command to terminal and you should see green text where Yggdrasil is printed with the words `[ACTIVE]` present.
You are now connected to the remote peer with Yggdrasil. If you see`[INACTIVE]`, then you need to check your code
for typos, make sure there are "" around the whole entire string.


# Grafana

[Grafana](https://grafana.com/) is a dashboard used to display Prometheus collected data.  Once installed you can visit `http://<yournodeip>:3000`.  Default login is `admin`/`admin`. You can skip the welcome screen/wizard by clicking on the Grafana logo at the top left corner.

## Known install bugs

At times Grafana will not start up properly during install and the dashboards will not install.  To install them manually run the following commands from the `prototype-cjdns/pi/scripts/grafana` folder

```
BASE_DIR=`pwd`
curl --user admin:admin -X POST -H 'Content-Type: application/json' --data-binary "@$BASE_DIR/datasource.json" http://localhost:3000/api/datasources
curl --user admin:admin -X POST -H 'Content-Type: application/json' --data-binary "@$BASE_DIR/dashboard.json" http://localhost:3000/api/dashboards/db
```
