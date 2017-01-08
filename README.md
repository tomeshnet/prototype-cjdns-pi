# prototype-cjdns-pi2

The following instructions will help you set up an encrypted mesh network based on Raspberry Pi 2's and 3's. It takes about 5 minutes to set up one node. Obviously, to have a mesh you will need more than one node.

## Set up

1. Make sure you have the following items:

    * A Raspberry Pi 2 or 3
    * An SD card that works with the Pi
    * A [TP-LINK TL-WN722N](http://www.tp-link.com/en/products/details/TL-WN722N.html)

1. Flash the SD card with [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/). 

1. Plug the SD card and TL-WN722N into the Pi.

1. Plug the Pi into your router, so it has connectivity to the Internet. SSH into the Pi with `ssh pi@raspberrypi.local` and password **raspberry**.

    **Optional:** There are other ways to connect, such as connecting the Pi to your computer and sharing Internet to it. Or if you have multiple Pi's connected to your router, find its IP with `nmap -sn 192.168.X.0/24` (where 192.168.X is your subnet) and SSH to the local IP assigned to the Pi you want to address `ssh pi@192.168.X.Y`.

1. In your SSH session, run `sudo raspi-config`.

   1. Select **Expand Filesystem** to use the full space on your SD card.
   
   1. Select **Change User Password** so others cannot remotely access your Pi with the default password.
   
   1. Reboot.

1. SSH back in with your new password and run the following, then let the installation complete. After about 5 minutes the Pi will reboot:

    ```
    $ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi2/master/scripts/install && chmod +x install && ./install
    ```

    **Optional:** If you have a TP-LINK TL-WN722N and want to configure it as a [802.11s Mesh Point](https://github.com/o11s/open80211s/wiki/HOWTO) interface, set the `WITH_MESH_POINT` flag to `true`.

    **Optional:** If you have a Raspberry Pi 3 and want to configure the on-board WiFi as an Access Point, set the `WITH_WIFI_AP` flag to `true`. The default configuration routes all traffic to the Ethernet port `eth0`. 

    **Optional:** If you want to install [IPFS](https://ipfs.io), set the `WITH_IPFS` flag to `true`.

    To install with all optional features:

    ```
    $ wget https://raw.githubusercontent.com/tomeshnet/prototype-cjdns-pi2/master/scripts/install && chmod +x install && WITH_MESH_POINT=true WITH_WIFI_AP=true WITH_IPFS=true ./install
    ```

## Check status

1. Give the Pi about 15 seconds to reboot and SSH back into it, then check the status with:

    ```
    $ ./prototype-cjdns-pi2/scripts/status
    ```

1. Verify that the **Mesh Interface** and **cjdns Service** are both active. The **NODE** section should display a single IPv6 address, that's the identity of your Pi in the cjdns mesh. The **PEERS** section should indicate a list of IPv6 addresses that are active peers to your node. This list will be empty, until you have another nearby node with the same set up.

## Network benchmark

You can benchmark the network throughput with more than one node. Let's name our two Pi's **Hillary** and **Friend**.

1. SSH to Friend and run `./prototype-cjdns-pi2/scripts/status`, note its IPv6.

1. Run `iperf3 -s` to start listening. Do not end the SSH session.

1. In another Terminal session, SSH to Hillary and run `iperf3 -c FRIEND_IPV6`. You should start seeing Hillary sending encrypted packets to her Friend. On a Pi 2, we can expect about 14 Mbps throughput, and 40 Mbps on a Pi 3.

## Update & Uninstall

To uninstall the services, run `./prototype-cjdns-pi2/scripts/uninstall`.

If you are updating, run the same uninstall script, but keep all configuration files and data directories when prompted, remove the **prototype-cjdns-pi2** directory along with the **install** script, then repeat the last installation step.

## Notes

* Your computer can be a node too! It will mesh with the Pi's over your router. See the [cjdns repository](https://github.com/cjdelisle/cjdns) on how to set this up.

* Plan for this repository and detailed benchmark results are available in [the doc folder](https://github.com/tomeshnet/prototype-cjdns-pi2/blob/master/docs/).
