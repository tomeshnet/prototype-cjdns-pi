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
Cjdns (Caleb James DeLisle's Network Suite) is a networking protocol and reference implementation. It is founded on the ideology that networks should be easy to set up, protocols should scale smoothly, and security should be ubiquitous.

If uses cryptography to self-assign IPv6 address in the fc00/8 subnet and will automatically peer with other nodes connected via Layer2 ethernet, broadcasts or configured UDP tunnels.

For more information please see the [CJDNS FAQ](https://github.com/cjdelisle/cjdns/blob/master/doc/faq/general.md)

### CJDNS Firewall
By default the following ports are open from CJDNS

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

To modify the ports that are accessable from CJDNS modify the `cjdns` *table* in the IPv6 firewall config file. (see the Firewall module for more details)

## Yggdrasil subnetting

Yggdrasil is another mesh routing software. It will give each node (like your Pi, for example) an IPv6 address, but it can also give each node a subnet to distribute to its clients. This means that if you connect the WiFi of your Pi, your device can get a unique Yggdrasil address, with all the benefits it provides. These include being able to access your device directly, without being NATed or blocked.

However, the Pi does have a firewall, so various commands need be run to allow access to clients.

### One client, one port

```
sudo ip6tables -A YGGDRASIL -j ACCEPT -p <PROTOCOL> -d <YGGDRASIL IP> --dport <PORT>
```
Example protocols are `tcp` or `udp`, and you'll have to figure out the port number depending on what you want to expose.
The Yggdrasil IP address of the client can be deduced by running `ifconfig` on Linux and Mac, and you'll see an IPv6 address starting with `30`. In Windows, type `ipconfig` in command prompt. If you're having issues, read [this article](https://www.groovypost.com/howto/find-windows-10-device-ip-address/).
Specifying a protocol is not required, but recommended.

### All clients, one port

```
sudo ip6tables -A YGGDRASIL -j ACCEPT -p <PROTOCOL> --dport <PORT>
```
Specifying a protocol is not required, but recommended.

### All clients, all ports

```
sudo ip6tables -A YGGDRASIL -j ACCEPT
```
Specifiying a protocol is possible here, but will limit what is opened.

### Saving so it works after reboots

```
sudo ip6tables-save > /etc/iptables/rules.v6
```

### Re-Blocking everything after adding rules

```
sudo ip6tables -F YGGDRASIL
```

### Removing a specific rule

This one's a tad more complicated.
First, run:
```
sudo ip6tables -nvL --line-numbers
```
Note the line number of the rule you want to remove. It'll be under the heading `Chain YGGDRASIL`.
Then run:
```
sudo ip6tables -R YGGDRASIL <number>
```

## IPFS
IPFS stands for Interplanetary File System and it is an open-source, peer-to-peer distributed hypermedia protocol that aims to function as a ubiquitous file system for all computing devices. 

This module will install IPFS under the user which the script is run, allowing you to access IPFS resouces both directly from the command line, and through the gateway available at <Pi Address>/ipfs/
  
## Firewall
  
The firewall module installed a basic firewall for your device. It will block all ports thare wre not ment to be open. By default there are no ports blocked from the Wireless Access Point interface.

## IPv4
Default open ports to the device

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

### Change open ports

To change the open ports you can edit the IPv4 configuration file located at `/etc/iptables/rules.v4`

Remove or comment out (#) the lines of the ports that you wish to close and add new lines for additional ports you wish to open.

These are standard `iptables` rules. The basic syntax is as follows:

`-A INPUT -p <protocol> -m <protocol> --dport <port> -j ACCEPT`

`protocol` -  either `tcp` or `udp`
`port` - Port you wish to open between 1-65535


## IPv6

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

### Change open ports

To change the open ports you can edit the IPv6 configuration file located at `/etc/iptables/rules.v6`

Remove or comment out (#) the lines of the ports that you wish to close and add new lines for additional ports you wish to open.

These are standard `ip6tables` rules. The basic syntax is as follows:

`-A <table> -p <protocol> -m <protocol> --dport <port> -j ACCEPT`

`table` - `INPUT` for general ports or specific tables as defined in the modules
`protocol` -  either `tcp` or `udp`
`port` - Port you wish to open between 1-65535
