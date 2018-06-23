# prototype-cjdns-pi

Prototype for cjdns on Raspberry Pi 2 forming a mesh network

This repository will track progress and hold documentation, scripts, benchmarking results and other findings along the way.

## Proposed setup

### Phase 1: Connect

- [x] Flash two [Raspberry Pi 2's with OpenWrt 15.05](https://wiki.openwrt.org/toh/raspberry_pi_foundation/raspberry_pi)
- [x] Install [MeshBox](https://github.com/SeattleMeshnet/meshbox) with `opkg update && opkg install luci-app-cjdns`
- [x] Attach a [Pi 2](http://elinux.org/RPi_USB_Wi-Fi_Adapters) + [OpenWrt](https://forum.openwrt.org/viewtopic.php?id=37331) + [802.11s](http://devel.open80211s.narkive.com/8olWVgz9/802-11s-and-raspberry-pi)-compatible USB WiFi adapter (e.g. TL-WN722N) and [install firmware](https://wiki.debian.org/ath9k_htc)
- [x] Configure network interface to run 802.11s [manually](https://wiki.openwrt.org/doc/howto/mesh.80211s) or through the MeshBox UI
- [x] Configure [802.11s on Raspbian Jessie](https://github.com/o11s/open80211s/wiki/HOWTO) and bind interface to the Pi 2 optimized cjdns

**Results:**

On OpenWrt or Raspbian, it's quite simple to set up cjdns over a 802.11s Mesh Point link. Raspbian allows for far better performance from CPU optimizations. The best Pi 2 results we have achieved is 14 Mbps over the cjdns interface. The throughput of the Mesh Point link without cjdns is about 50 Mbps TCP and 70 Mbps UDP, which means we haven't been able to saturate the 802.11n mesh link due to CPU-bound cjdns crypto and routing.

Would like to try this on more powerful boards such as the Pi 3 and [ODROID-C2](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G145457216438). A rough estimate would be a 2-3x boost in cjdns throughput based on other benchmarks done on these boards. [Off-loading CPU-intensive NaCl encryption to dedicated hardware blocks](https://www.reddit.com/r/hyperboria/comments/1flpty/how_to_get_your_beaglebone_black_running_cjdns/) is also an option. Unfortunately the hardware implementations aren't available on the Pi 3 or ODROID-C2, though these may become more common in future SoCs.

To set up on the Pi 2, flash Raspbian Jessie, SSH in and expand your filesystem to fill the available space on your SD card using `sudo raspi-config`. Ensure that your Pi 2 has internet connectivity, then run [install](https://github.com/tomeshnet/prototype-cjdns-pi/blob/master/scripts/install):

```
wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/master/scripts/install && chmod +x install && ./install
```

[See the full report.](https://github.com/tomeshnet/prototype-cjdns-pi/blob/master/docs/phase-1-connect.md)

### Phase 2: Range

- [x] Swap out the N connector antenna on the radio to a directional antenna for range (e.g. TL-ANT2424B), via a N Male to RP-SMA Female "Pigtail" (e.g. TL-ANT24PT3)
- [x] Attach [long-range point-to-point antenna](https://www.ubnt.com/products/) (e.g. NanoStation M5)

**Results:**

Tested at 100 m with homemade Pigtails and Cantennas. Longer range tests in more controlled environments needed.

More on Cantennas:

* https://propakistani.pk/2010/03/19/how-cantenna-works-technically/
* http://www.binarywolf.com/249/coffee_can_antenna.htm
* http://www.csgnetwork.com/antennawncalc.html

### Phase 3: Hyperboria

- [x] Connect one Pi 2 to the internet through the Ethernet port
- [x] Through the MeshBox UI, peer the Pi 2 into [Hyperboria](https://www.fc00.org) by configuring a VPN tunnel with the cjdns UDP interface
- [x] Make the Pi 2 a [gateway node to the internet](https://github.com/hyperboria/cjdns/blob/master/doc/tunnel.md)

**Results:**

MeshBox isn't used, but we have configured the Pi to connect to an Internet gateway on Hyperboria, and exits all LAN traffic through that.

### Phase 4: Access

- [x] Set up the other Pi 2 as a [IPv6-only router and NAT gateway](https://github.com/hyperboria/cjdns/blob/master/doc/nat-gateway.md) for devices to connect and access both Hyperboria and internet resources (the latter over the point-to-point link, through the first Pi 2's internet gateway)
- [x] Allow IPv4-only devices to connect by [tunneling IPv4 traffic through the IPv6 cjdns link](https://en.wikipedia.org/wiki/4in6)

**Results:**

The scripted install on a Pi 3 sets up an Access Point with the onboard WiFi and routes both Internet and Hyperboria traffic for LAN devices that aren't running a cjdns client.

## Relevant links

* https://github.com/openwrt-routing/packages
* http://raspberrypihq.com/how-to-turn-a-raspberry-pi-into-a-wifi-router/
* https://www.wifipineapple.com/
* http://battlemesh.org/BattleMeshV4/MeshGuide

## Credits

* [The cjdns community](https://github.com/hyperboria)
* [The Layer 8 Network](http://layer8.network)
