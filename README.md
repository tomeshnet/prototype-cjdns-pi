# prototype-cjdns-pi2

Prototype for cjdns on Raspberry Pi 2 forming a mesh network

This repository will track progress and hold documentation, scripts, benchmarking results and other findings along the way.

## Proposed setup

- [ ] Flash two [Raspberry Pi 2's with OpenWrt 15.05](https://wiki.openwrt.org/toh/raspberry_pi_foundation/raspberry_pi)
- [ ] Install [MeshBox](https://github.com/SeattleMeshnet/meshbox) with `opkg update && opkg install luci-app-cjdns`
- [ ] Attach a [Raspberry Pi 2](http://elinux.org/RPi_USB_Wi-Fi_Adapters) + [OpenWrt](https://forum.openwrt.org/viewtopic.php?id=37331) + [802.11s](http://devel.open80211s.narkive.com/8olWVgz9/802-11s-and-raspberry-pi)-compatible USB WiFi adapter (e.g. TL-WN722N) and [install firmware](https://wiki.debian.org/ath9k_htc)
- [ ] Configure network interface to run 802.11s [manually](https://wiki.openwrt.org/doc/howto/mesh.80211s) or through the MeshBox UI
- [ ] Attach [long-range point-to-point antenna](https://www.ubnt.com/products/) (e.g. NanoStation M5)

## Relevant links

* https://github.com/openwrt-routing/packages
* http://raspberrypihq.com/how-to-turn-a-raspberry-pi-into-a-wifi-router/
* https://www.wifipineapple.com/

## Credits

* [The cjdns community](https://github.com/hyperboria)
* [The Layer 8 Network](http://layer8.network)
