# prototype-cjdns-pi

The following instructions will help you set up an encrypted mesh network on Raspberry Pi's. It takes about 5 minutes to set up a node with the Pi 3. Obviously, to have a mesh you will need more than one node.

## Set up

1. Make sure you have the following items:

    * A Raspberry Pi Zero, 1, 2, or 3 (Pi 3 recommended)
    * An SD card that works with the Pi
    * A USB WiFi adapter with [802.11s Mesh Point](https://github.com/o11s/open80211s/wiki/HOWTO) support, such as the [TP-LINK TL-WN722N](http://www.tp-link.com/en/products/details/TL-WN722N.html) (optional)

1. Flash the SD card with [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/).

1. Create an empty file named **ssh** to enable SSH when the Pi boots:

    ```
    $ touch /path/to/sd/boot/ssh
    ```

1. Plug the SD card and USB WiFi adapter into the Pi.

1. Plug the Pi into your router, so it has connectivity to the Internet. SSH into the Pi with `ssh pi@raspberrypi.local` and password **raspberry**.

    **Optional:** There are other ways to connect, such as connecting the Pi to your computer and sharing Internet to it. Or if you have multiple Pi's connected to your router, find its IP with `nmap -sn 192.168.X.0/24` (where 192.168.X is your subnet) and SSH to the local IP assigned to the Pi you want to address `ssh pi@192.168.X.Y`.

1. In your SSH session, run `passwd` and change your login password. It is very important to choose a strong password so others cannot remotely access your Pi.

1. Run the following, then let the installation complete. After about 5 minutes the Pi will reboot:

    ```
    $ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/master/scripts/install && chmod +x install && ./install
    ```

    **Optional:** If you have a suitable USB WiFi adapter and want to configure it as a 802.11s Mesh Point interface, set the `WITH_MESH_POINT` flag to `true`.

    **Optional:** If you have a Raspberry Pi 3 and want to configure the on-board WiFi as an Access Point, set the `WITH_WIFI_AP` flag to `true`. The default configuration routes all traffic to the Ethernet port `eth0`.

    **Optional:** If you want to install [IPFS](https://ipfs.io), set the `WITH_IPFS` flag to `true`.

    **Optional:** If you want to install non-essential tools useful for network analysis, set the `WITH_EXTRA_TOOLS` flag to `true`.

    To install with all optional features:

    ```
    $ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/master/scripts/install && chmod +x install && WITH_MESH_POINT=true WITH_WIFI_AP=true WITH_IPFS=true WITH_EXTRA_TOOLS=true ./install
    ```

## Check status

1. Give the Pi about 15 seconds to reboot and SSH back into it. You should find the status of your mesh node automatically printed. You can also print this anytime by running `status`.

1. Verify that **cjdns Service** is active, and **Mesh Interface** (if applicable). The **NODE** section should display a single IPv6 address, that's the identity of your Pi in the cjdns mesh. The **PEERS** section should indicate a list of IPv6 addresses that are active peers to your node. This list will be empty, until you have another nearby node with the same set up.

## Network benchmark

You can benchmark the network throughput with more than one node. Let's name our two Pi's **Hillary** and **Friend**.

1. SSH to Friend and note its IPv6.

1. Run `iperf3 -s` to start listening. Do not end the SSH session.

1. In another Terminal session, SSH to Hillary and run `iperf3 -c FRIEND_IPV6`. You should start seeing Hillary sending encrypted packets to her Friend. See [phillymesh/cjdns-optimizations](https://github.com/phillymesh/cjdns-optimizations) for expected throughput.

## Update & Uninstall

To uninstall the services, run `./prototype-cjdns-pi/scripts/uninstall`.

If you are updating, run the same uninstall script, but keep all configuration files and data directories when prompted, remove the **prototype-cjdns-pi** directory along with the **install** script, then repeat the last installation step.

## Development

You can install from a specific tag or branch, such as `develop`, with:

```
$ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/develop/scripts/install && chmod +x install && TAG_PROTOTYPE_CJDNS_PI=develop ./install
```

If you are developing on a forked repository, such as `me/prototype-cjdns-pi`, then:

```
$ wget https://raw.githubusercontent.com/me/prototype-cjdns-pi/develop/scripts/install && chmod +x install && GIT_PROTOTYPE_CJDNS_PI="https://github.com/me/prototype-cjdns-pi.git" TAG_PROTOTYPE_CJDNS_PI=develop ./install
```

## Notes

* Your computer can be a node too! It will mesh with the Pi's over your router. See the [cjdns repository](https://github.com/cjdelisle/cjdns) on how to set this up.

* Original plan for this repository and early benchmark results are available in [the doc folder](https://github.com/tomeshnet/prototype-cjdns-pi/blob/master/docs/).
