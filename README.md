# prototype-cjdns-pi

[![Build Status](https://travis-ci.org/tomeshnet/prototype-cjdns-pi.svg?branch=master)](https://travis-ci.org/tomeshnet/prototype-cjdns-pi)

The following instructions will help you set up an encrypted mesh network on Raspberry Pi's. It takes about 15 minutes to set up a node with the Pi 3. Obviously, to have a mesh you will need more than one node. 

Many models of Orange Pi hardware running [Armbian](https://www.armbian.com/) are also supported. The same installation steps can be followed, except you would flash the SD card with Armbian instead of Raspbian. See [Hardware Table](#hardware-table) for the full list of supported hardware.

## Set Up

1. Make sure you have the following items:

    * Raspberry Pi Zero, 1, 2, 3 (Pi 3 recommended), or for advanced users other [compatible hardware](#hardware-table)
    * An SD card that works with the Pi
    * **Optional:** A USB WiFi adapter with [802.11s Mesh Point](https://github.com/o11s/open80211s/wiki/HOWTO) support, such as the [TP-LINK TL-WN722N](http://www.tp-link.com/en/products/details/TL-WN722N.html) or [Toplinkst TOP-GS07](https://github.com/tomeshnet/documents/blob/master/technical/20170208_mesh-point-with-topgs07-rt5572.md)

1. Flash the SD card with [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/).

1. Create an empty file named **ssh** to enable SSH when the Pi boots:

    ```
    $ touch /path/to/sd/boot/ssh
    ```

1. Plug the SD card and USB WiFi adapter into the Pi.

1. Plug the Pi into your router, so it has connectivity to the Internet. SSH into the Pi with `ssh pi@raspberrypi.local` and password **raspberry**.

    **Optional:** There are other ways to connect, such as connecting the Pi to your computer and sharing Internet to it. Or if you have multiple Pi's connected to your router, find its IP with `nmap -sn 192.168.X.0/24` (where 192.168.X is your subnet) and SSH to the local IP assigned to the Pi you want to address `ssh pi@192.168.X.Y`.  

    **Note:** After the install the node will be renamed to tomesh-xxxx where xxxx is the last 4 characters of your CJDNS address.  Before the reboot the node will notify you of what the name is.

1. In your SSH session, run `passwd` and change your login password. It is very important to choose a strong password so others cannot remotely access your Pi.

1. Run the following, then let the installation complete. After about 5 minutes the Pi will reboot:

    ```
    $ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/master/scripts/install && chmod +x install && ./install
    ```
    
    The installation script can also install many optional features such as distributed applications and network analysis tools that are useful but non-essential to run a node. You can use flags to selectively enable them, or use the following command to install all optional features:

    ```
    $ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/master/scripts/install && chmod +x install && WITH_MESH_POINT=true WITH_WIFI_AP=true WITH_FIREWALL=true WITH_CJDNS_IPTUNNEL=true WITH_IPFS=true WITH_PROMETHEUS_NODE_EXPORTER=true WITH_PROMETHEUS_SERVER=true WITH_GRAFANA=true WITH_H_DNS=true WITH_H_NTP=true WITH_EXTRA_TOOLS=true ./install
    ```

## Optional Features

| Feature Flag                    | HTTP Service Port                              | Description |
| :------------------------------ | :--------------------------------------------- | :---------- |
| `WITH_MESH_POINT`               | None                                           | Set to `true` if you have a suitable USB WiFi adapter and want to configure it as a 802.11s Mesh Point interface. |
| `WITH_WIFI_AP`                  | None                                           | Set to `true` if you have a Raspberry Pi 3 and want to configure the on-board WiFi as an Access Point. The default configuration routes all traffic to the Ethernet port `eth0`. |
| `WITH_FIREWALL`                 | None                                           | Set to `true` if you want to enable a basic firewall on your node.|
| `WITH_CJDNS_IPTUNNEL`           | None                                           | Set to `true` if you want to use the cjdns iptunnel feature to set up an Internet gateway for your node. To configure as a server (exit Internet traffic for other nodes), create **/etc/cjdns.iptunnel.server** containing a newline-separated list of cjdns public keys of allowed clients. To configure as a client (use an exit server to access the Internet), create **/etc/cjdns.iptunnel.client** containing a newline-separated list of cjdns public keys of the gateway servers. You can only configure as one or the other, not both. |
| `WITH_IPFS`                     | **80**: HTTP-to-IPFS gateway at `/ipfs/HASH`   | Set to `true` if you want to install [IPFS](https://ipfs.io). |
| `WITH_PROMETHEUS_NODE_EXPORTER` | **9100**: Node Exporter UI                     | Set to `true` if you want to install [Prometheus Node Exporter](https://github.com/prometheus/node_exporter) to report network metrics. |
| `WITH_PROMETHEUS_SERVER`        | **9090**: Prometheus Server UI                 | Set to `true` if you want to install [Prometheus Server](https://github.com/prometheus/prometheus) to collect network metrics. *Requires Prometheus Node Exporter.* |
| `WITH_GRAFANA`                  | **3000**: Grafana UI (login: admin/admin)      | Set to `true` if you want to install [Grafana](https://grafana.com) to display network metrics. *Requires Prometheus Server.* |
| `WITH_H_DNS`                    | None                                           | Set to `true` if you want to use Hyperboria-compatible DNS servers: `fc4d:c8e5:9efe:9ac2:8e72:fcf7:6ce8:39dc`, `fc6e:691e:dfaa:b992:a10a:7b49:5a1a:5e09`, and `fc16:b44c:2bf9:467:8098:51c6:5849:7b4f` |
| `WITH_H_NTP`                    | None                                           | Set to `true` if you want to use a Hyperboria-compatible NTP server: `fc4d:c8e5:9efe:9ac2:8e72:fcf7:6ce8:39dc` |
| `WITH_EXTRA_TOOLS`              | None                                           | Set to `true` if you want to install non-essential tools useful for network analysis: vim socat oping bmon iperf3 |

If you are connected to the WiFi Access Point, all HTTP services are available via `http://10.0.0.1:PORT` as well as the cjdns IPv6. To connect with the cjdns address, first note your node's fc00::/8 address from `status`, then navigate to `http://[fcaa:bbbb:cccc:dddd:eeee:0000:1111:2222]:PORT` from your browser.

## Check Status

1. Give the Pi about 15 seconds to reboot and SSH back into it. You should find the status of your mesh node automatically printed. You can also print this anytime by running `status`.

1. Verify that **cjdns Service** is active, and **Mesh Interface** (if applicable). The **NODE** section should display a single IPv6 address, that's the identity of your Pi in the cjdns mesh. The **PEERS** section should indicate a list of IPv6 addresses that are active peers to your node. This list will be empty, until you have another nearby node with the same set up.

## Network Benchmark

You can benchmark the network throughput with more than one node. Let's name our two Pi's **Hillary** and **Friend**.

1. SSH to Friend and note its IPv6.

1. Run `iperf3 -s` to start listening. Do not end the SSH session.

1. In another Terminal session, SSH to Hillary and run `iperf3 -c FRIEND_IPV6`. You should start seeing Hillary sending encrypted packets to her Friend. See [phillymesh/cjdns-optimizations](https://github.com/phillymesh/cjdns-optimizations) for expected throughput.

## Update & Uninstall

To uninstall the services, run `./prototype-cjdns-pi/scripts/uninstall`.

If you are updating, run the same uninstall script, but keep all configuration files and data directories when prompted, remove the **prototype-cjdns-pi** directory along with the **install** script, then repeat the last installation step.

## Experimental Support for Orange Pi

We are adding support for [Orange Pi](http://www.orangepi.org/) boards and have tested with the [Orange Pi Zero (Armbian nightly)](https://dl.armbian.com/orangepizero/nightly/), [Orange Pi One (Armbian nightly)](https://dl.armbian.com/orangepione/nightly/), and [Orange Pi Lite  (Armbian nightly)](https://dl.armbian.com/orangepilite/nightly/). Instead of flashing Raspbian, start with the Armbian nightly images linked above, then follow the same installation steps as the Raspberry Pi.

## Hardware Table

List of tested hardware:

| Hardware                  | Base OS         | [CJDNS Benchmark](https://github.com/phillymesh/cjdns-optimizations) <sub>(salsa20/poly1305, switching)</sub> | iPerf3 | USB | Ethernet | Notes    |
| :-------------------------|:----------------|:--------------------------------------------------------------------------------------------------------------|:-------|:----|:---------|:---------|
| Raspberry Pi 3            | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/)         | 350k, 100k | 89 Mbps | 2       | 10/100 |                                                 |
| Raspberry Pi 2            | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/)         | 150k,  50k |         | 2       | 10/100 |                                                 |
| Raspberry Pi 1 A+         | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/)         |  35k,   -  | ~9 Mbps | 1       | None   |                                                 |
| Raspberry Pi 1 B+         | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/)         |  51k,  22k | ~9 Mbps | 2       | 10/100 |                                                 |
| Raspberry Pi Zero         | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/)         |  68k,  30k | ~9 Mbps | 1*      | None   | *Need OTG Cable No FPV                          |
| Orange Pi Lite            | [Armbian Nightly](https://dl.armbian.com/orangepilite/nightly/)          | 160k,  74k | 67 Mbps | 2       | None   |                                                 |
| Orange Pi One             | [Armbian Nightly](https://dl.armbian.com/orangepione/nightly/)           | 160k,  74k | 67 Mbps | 1       | 10/100 |                                                 |
| Orange Pi Zero            | [Armbian Nightly](https://dl.armbian.com/orangepizero/nightly/)          | 160k,  74k | 67 Mbps | 1 (+2*) | 10/100 | *USB Headers                                    |
| Orange Pi Zero Plus 2 H5  | [Armbian Nightly](https://dl.armbian.com/orangepizeroplus2-h5/nightly/)  | 190k, 130K | 80 Mbps | 0 (+2*) | None   | *USB Headers                                    |
| NanoPi Neo 2              | [Armbian Nightly](https://dl.armbian.com/nanopineo2/nightly/)            | 160k, 95K  | 67 Mbps | 1 (+2*) | 10/100/1000   | *USB Headers, Gigabit Eth                |
| Rock64                    | [Armbian Nightly](https://dl.armbian.com/rock64/nightly/)                | 255k, 168K | 94 Mbps | 3       | 10/100/1000   | 1 USB 3.0, Gigabit Eth                   |
| EspressoBin               | [Armbian Nightly](https://dl.armbian.com/espressobin/nightly/)           | 186k, 128K | 73 Mbps | 2       | 10/100/1000   | 1 USB 3.0, 2x Gigabit Eth, Sata, mPCIE   |

## Development

You can install from a specific tag or branch, such as `develop`, with:

```
$ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/develop/scripts/install && chmod +x install && TAG_PROTOTYPE_CJDNS_PI=develop ./install
```

If you are developing on a forked repository, such as `me/prototype-cjdns-pi`, then:

```
$ wget https://raw.githubusercontent.com/me/prototype-cjdns-pi/develop/scripts/install && chmod +x install && GIT_PROTOTYPE_CJDNS_PI="https://github.com/me/prototype-cjdns-pi.git" TAG_PROTOTYPE_CJDNS_PI=develop ./install
```

To add a new module, use **scripts/ipfs/** as an example to:

* Create a `WITH_NEW_MODULE` tag
* Create **scripts/new-module/install** and **scripts/new-module/uninstall**
* Make corresponding references in the main **install**, **install2**, **status**, **uninstall** files

## Notes

* Your computer can be a node too! It will mesh with the Pi's over your router. See the [cjdns repository](https://github.com/cjdelisle/cjdns) on how to set this up.

* Original plan for this repository and early benchmark results are available in [the doc folder](https://github.com/tomeshnet/prototype-cjdns-pi/blob/master/docs/).

## FAQ

**Q:** Why do my Orange Pi Zero USB headers not work?

**A:** Some images are missing the USB overlay.  Simply add the following to the **/boot/armbianEnv.txt** file and restart the pi.
`overlays=usbhost2 usbhost3`


**Q:** Why do I get an error about a locked file when I try to install the node on an Orange Pi?

**A**: The daily apt upgrade sometimes starts up in the background locking the APT database. This will cause the script to fail as it tries to install the required software. Wait for the upgrade to finish.


**Q:** Can I connect a serial cable (ttl) to a Raspberry Pi (or Rock64)?

**A:** Yes, there are TTL pins in the gpio pins. They are as follows  
```
VCC → RPi Pin 02 (5V)
GND → RPi Pin 06
RXD → RPi Pin 08
TXD → RPi Pin 10
```
*Note: Uboot will not appear on serial, only once kernal starts to boot do you see output*

**Q:** What is the baud rate for the Rock64?

**A:** Uboot baud rate seems to be 1500000. Once ubuntu starts it is 115200

**Q:** How do I upgrade the uBoot on EspressoBin?

**A:** Manual flashing to latest u-boot is mandatory! [Download](https://dl.armbian.com/espressobin/u-boot/) the right boot flash for your board: 512,1G,2G and appropriate memory speeds. You can obtain numbers from current boot prompt. Copy this flash-image-MEM-CPU_DDR_boot_sd_and_usb.bin to your FAT formatted USB key, plug it into USB3.0 port and execute from u-boot prompt: 

   ```
   bubt flash-image-MEM-CPU_DDR_boot_sd_and_usb.bin spi usb
   ````

**Q:** How do I boot Armbian on EspressoBin from sd card?

**A:** First update the uboot (above). Then run the following in uBoot.

```
setenv verbosity 2
setenv boot_interface mmc
setenv image_name boot/Image
setenv fdt_name boot/dtb/marvell/armada-3720-community.dtb
setenv fdt_high "0xffffffffffffffff"
setenv rootdev "/dev/mmcblk0p1"
setenv rootfstype "ext4"
setenv verbosity "1"
setenv initrd_addr "0x1100000"
setenv initrd_image "boot/uInitrd"
setenv bootcmd 'mmc dev 0; ext4load mmc 0:1 $kernel_addr $image_name;ext4load mmc 0:1 $initrd_addr $initrd_image; ext4load mmc 0:1 $fdt_addr $fdt_name; setenv bootargs $console root=$rootdev rw rootwait; booti $kernel_addr $initrd_addr $fdt_addr'

save env
```

