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
| 9100  | TCP     | Accept | NodeExporter              |
| 5201  | TCP     | Accept | IPerf3                    |
| 4001  | TCP     | Accept | IPFS Swarm port           |

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