# prototype-cjdns-pi

[![Build Status](https://travis-ci.org/tomeshnet/prototype-cjdns-pi.svg?branch=master)](https://travis-ci.org/tomeshnet/prototype-cjdns-pi)

The following instructions will help you set up an encrypted mesh network on Raspberry Pi's. It takes about 15 minutes to set up a node with the Pi 3. Obviously, to have a mesh you will need more than one node. 

Many board that run [Armbian](https://www.armbian.com/) such as many models of Orange Pi hardware are also supported. The same installation steps can be followed, except you would flash the SD card with Armbian instead of Raspbian. See [Hardware Table](#hardware-table) for the full list of supported hardware and check for board specific installation details in our [Frequently Asked Questions](./docs/FAQ.md).

## Set Up

1. Make sure you have the following items:

    * Raspberry Pi Zero, 1, 2, 3 (Pi 3 recommended), or for advanced users other [compatible hardware](#hardware-table)
    * An SD card that works with the Pi
    * **Optional:** A USB WiFi adapter: 
      * For [802.11s Mesh Point](https://github.com/o11s/open80211s/wiki/HOWTO) wireless links (recommended), device such as the [TP-LINK TL-WN722N v1](http://www.tp-link.com/en/products/details/TL-WN722N.html), [Toplinkst TOP-GS07](https://github.com/tomeshnet/documents/blob/master/technical/20170208_mesh-point-with-topgs07-rt5572.md) or [another supported device](https://github.com/phillymesh/802.11s-adapters/blob/master/README.md).
      * For [ad-hoc](https://en.wikipedia.org/wiki/Wireless_ad_hoc_network) wireless links (experimental), any device that supports linux and ad-hoc.

1. Flash the SD card with [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/).

1. Create an empty file named **ssh** to enable SSH when the Pi boots:

    ```
    $ touch /path/to/sd/boot/ssh
    ```

1. Plug the SD card and USB WiFi adapter into the Pi.

1. Plug the Pi into your router so it has connectivity to the Internet. SSH into the Pi with `ssh pi@raspberrypi.local` and password **raspberry**.

    **Optional:** There are other ways to connect, such as connecting the Pi to your computer and sharing Internet to it. If you have multiple Pi's connected to your router, find their IPs with `nmap -sn 192.168.X.0/24` (where 192.168.X is your subnet) and SSH to the local IP assigned to the Pi you want to address `ssh pi@192.168.X.Y`.  

    **Note:** After the install the node will be renamed to `tomesh-xxxx` where `xxxx` is the last 4 characters of your CJDNS address.  Before the reboot the node will notify you of what the name is.

1. In your SSH session, run `passwd` and change your login password. It is very important to choose a strong password so others cannot remotely access your Pi.

1. Run the following, then let the installation complete. After about 5 minutes the Pi will reboot:

    ```
    $ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi/master/scripts/install && chmod +x install && ./install
    ```

## Modules

During the installation, you may be able to pick a profile, or choose between many modules. To learn what each module is for, look at [MODULES.md](./docs/MODULES.md). This is important for the installation.

## Check Status

1. Give the Pi about 15 seconds to reboot and SSH back into it. You should find the status of your mesh node automatically printed. You can also print this anytime by running `status`.

2. Verify that **cjdns Service** is active, and **Mesh Interface** (if applicable). The **NODE** section should display a single IPv6 address, that's the identity of your Pi in the cjdns mesh. The **PEERS** section should indicate a list of IPv6 addresses that are active peers to your node. This list will be empty, until you have another nearby node with the same set up.

## Network Benchmark

You can benchmark the network throughput with more than one node. Let's name our two Pi's **Hillary** and **Friend**.

1. SSH to Friend and note its IPv6.

1. Run `iperf3 -s` to start listening. Do not end the SSH session.

1. In another Terminal session, SSH to Hillary and run `iperf3 -c FRIEND_IPV6`. You should start seeing Hillary sending encrypted packets to her Friend. See [phillymesh/cjdns-optimizations](https://github.com/phillymesh/cjdns-optimizations) for expected throughput.

## Update & Uninstall

To uninstall the services, run `./prototype-cjdns-pi/scripts/uninstall`.

If you are updating, run the same uninstall script, but keep all configuration files and data directories when prompted, remove the **prototype-cjdns-pi** directory along with the **install** script, then repeat the last installation step.

## Experimental Support for Other Boards

We have added support for other single board computers such as the [Orange Pi](http://www.orangepi.org) family of boards. So far all the boards that have been tested support [Armbian](http://www.armbian.com) and usualy our install script needs no modification to work.  To use one of these boards start with the Armbian nightly images linked in the table below, then follow the same installation steps as the Raspberry Pi.  Below is a table of boards we have tested and some metrics of what you can expect from the board.

## Hardware Table

List of tested hardware:

| Hardware                  | Base OS         | [CJDNS Benchmark](https://github.com/phillymesh/cjdns-optimizations) <sub>(salsa20/poly1305, switching)</sub> | iPerf3 | USB | Ethernet | Notes    |
| :-------------------------|:----------------|:--------------------------------------------------------------------------------------------------------------|:-------|:----|:---------|:---------|
| Raspberry Pi 3b+          | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) | 405k, 119k | ~90 Mbps| 2       | 10/100/1000 | Eth only ~320mbps. Onboard wifi dual band |
| Raspberry Pi 3b           | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) | 350k, 100k | 89 Mbps | 2       | 10/100 | |
| Raspberry Pi 2            | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) | 145k,  55k | 39 Mbps | 2       | 10/100 | |
| Raspberry Pi 1 A+         | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) |  35k,   -  | ~9 Mbps | 1       | None   | |
| Raspberry Pi 1 B+         | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) |  51k,  22k | ~8 Mbps | 2       | 10/100 | |
| Raspberry Pi Zero         | [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) |  68k,  30k | ~9 Mbps | 1*      | None   | *Need OTG Cable No FPV |
| Orange Pi Lite            | [Armbian](https://dl.armbian.com/orangepilite/)                  | 160k,  74k | 67 Mbps | 2       | None   | |
| Orange Pi One             | [Armbian](https://dl.armbian.com/orangepione/)                   | 160k,  74k | 67 Mbps | 1       | 10/100 | |
| Orange Pi Zero            | [Armbian](https://dl.armbian.com/orangepizero/)                  | 160k,  74k | 67 Mbps | 1 (+2*) | 10/100 | *USB Headers |
| Orange Pi Zero Plus 2 H5  | [Armbian](https://dl.armbian.com/orangepizeroplus2-h5/)          | 190k, 130K | 80 Mbps | 0 (+2*) | None   | *USB Headers |
| NanoPi Neo 2              | [Armbian](https://dl.armbian.com/nanopineo2/)                    | 160k, 95K  | 67 Mbps | 1 (+2*) | 10/100/1000   | *USB Headers, Gigabit Eth |
| Rock64                    | [Armbian](https://dl.armbian.com/rock64/)                        | 255k, 168K | 94 Mbps | 3       | 10/100/1000   | 1 USB 3.0, Gigabit Eth |
| Pine64                    | [Armbian](https://dl.armbian.com/pine64/)                        | 227k, 151k | 78 Mbps | 2       | 10/100/1000   |  Gigabit Eth |
| ESPRESSObin               | [Armbian](https://dl.armbian.com/espressobin/)                   | 186k, 128K | 73 Mbps | 2       | 10/100/1000   | 1 USB 3.0, 3x Gigabit Eth, SATA, mPCIe. Use stable and apt-get upgrade after boot |
| MK802ii       | Debian | 30k, 40k | 25Mbps | | | Android box. Single core. Onboard WiFi supports Mesh Point |

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

* We keep a list of [Frequently Asked Questions](./docs/FAQ.md). Feel free to add to this list with the issues you experienced on your boards.

* Your computer can be a node too! It will mesh with the Pi's over your router. See the [cjdns repository](https://github.com/cjdelisle/cjdns) on how to set this up.

* Original plan for this repository and early benchmark results are available in [the doc folder](./docs).
