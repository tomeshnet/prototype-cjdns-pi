# Phase 1: Connect

## Set up

1. Download the [openwrt-15.05-brcm2708-bcm2709-sdcard-vfat-ext4.img](http://downloads.openwrt.org/chaos_calmer/15.05/brcm2708/bcm2709/) and [flash your SD card](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).

1. Connect to the default IP [http://192.168.1.1](http://192.168.1.1) and set a password to enable SSH. Optionally enable DHCP.

1. SSH in the Pi 2 as **root** and install cjdns with `opkg update && opkg install luci-app-cjdns`.

1. Install USB WiFi adapter drivers with `opkg install kmod-ath9k-htc kmod-ath9k-common`.

1. Create **/etc/config/wireless** with content:

	```
	config wifi-device radio0
	        option type     mac80211
	        option channel  11
	        option hwmode   11g
	        option path     'platform/bcm2708_usb/usb1/1-1/1-1.4/1-1.4:1.0'
	        option htmode   HT20

	config wifi-iface 'mesh'
	        option network    'mesh'
	        option device     'radio0'
	        option mode       'mesh'
	        option mesh_id    'mymesh'
	        option encryption 'none'
	```

1. Append the following lines to **/etc/config/network**:

	```
	config interface 'mesh'
	        option proto 'none'
	        option type  'bridge'
	```

1. In the MeshBox UI, under the cjdns **Settings** tab, bind `br-mesh` as an **Ethernet Interface**. Verify the following is added as an `ETHInterface` in your **cjdroute.conf**:

	```
	{
	  "beacon": 2,
	  "bind": "br-mesh",
	  "connectTo": []
	}
	```

1. Set up another Raspberry Pi 2 with the same configurations and the two should appear as each other's cjdns peer in the MeshBox UI.

## Benchmark

### Network Benchmark

Install network benchmarking tools with `opkg install iperf3 netperf`.

To use **iperf3**, run `iperf3 -s` on one Pi 2 to set up a server, then run `iperf3 -c CJDNS_IPV6` on the other, where **CJDNS_IPV6** is the cjdns node IPv6 address of the first Pi 2.

To use **netperf**, replace the commands with `netserver -D` and `netperf -H CJDNS_IPV6`, respectively.

The two benchmarking tools yield similar results. Here are the ones from iperf3.

**Between the two Pi 2s**

These results are similar regardless of whether the Pi 2s are peered over the 802.11s mesh link or LAN.

```
[ ID] Interval           Transfer     Bandwidth       Retr
[  5]   0.00-10.46  sec  2.94 MBytes  2.35 Mbits/sec   25             sender
[  5]   0.00-10.46  sec  2.63 MBytes  2.11 Mbits/sec                  receiver
```

**Laptop and VPS**

This is cjdns traffic bandwidth between my MacBook Pro with a 2.4 GHz Intel Core i5 and my VPS. Note that my internet connection is on a 50/50 Mbps package.

```
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-10.00  sec   101 MBytes  84.6 Mbits/sec                  sender
[  4]   0.00-10.00  sec   101 MBytes  84.4 Mbits/sec                  receiver
```

**Laptop to Pi 2**

This is over my local LAN, with both my laptop and the Pi 2 connected to my router.

```
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-10.01  sec  2.50 MBytes  2.10 Mbits/sec                  sender
[  4]   0.00-10.01  sec  2.29 MBytes  1.92 Mbits/sec                  receiver
```

**Laptop -> VPS -> Public Peer -> Pi 2**

Here I have the Pi 2 peered to the same public peer as my VPS over the UDP Interface.

```
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-10.00  sec  1.95 MBytes  1.63 Mbits/sec                  sender
[  4]   0.00-10.00  sec  1.87 MBytes  1.57 Mbits/sec                  receiver
```

**Laptop -> VPS -> Public Peer -> Pi 2 --> Pi 2**

The first Pi 2 is the same one peered to the public peer, and the second one connected to it over the 802.11s mesh link.

```
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-10.01  sec   706 KBytes   578 Kbits/sec                  sender
[  4]   0.00-10.01  sec   586 KBytes   480 Kbits/sec                  receiver
```

Regardless of the number of hops or the underlying physical interface, the Pi 2 seems to be limited to a 2 Mbps bandwidth. My laptop is doing 84 Mbps, probably just bound by my internet speeds.

### cjdns Benchmark

Find **/usr/sbin/cjdroute** and run `cjdroute --bench`.

**Pi 2**

```
Benchmark salsa20/poly1305 in 315637ms. 3801 kilobits per second
Benchmark Switching in 114787ms. 8920 packets per second
```

During benchmarking, one of four Pi 2 cores is fully utilized. The 3.8 Mbps crypto throughput explains the 2 Mbps network bandwidth. The poor performance is CPU-bound. We also ran the same benchmarking on a Pi 1, while my laptop is easily doing 1.2 Gbps on the crypto.

**Pi**

```
Benchmark salsa20/poly1305 in 619416ms. 1937 kilobits per second
Benchmark Switching in 371968ms. 2752 packets per second
```

**Laptop**

```
Benchmark salsa20/poly1305 in 974ms. 1232032 kilobits per second
Benchmark Switching in 2774ms. 369142 packets per second
```

#### cjdns on Raspbian

Flash **Raspbian Jessie** and SSH in the Pi 2 with `ssh pi@raspberrypi.local`. The default password is **raspberry**. Clone cjdns with `git clone https://github.com/hyperboria/cjdns.git` and compile with `NO_TEST=1 Seccomp_NO=1 ./do`. More on the flags [here](http://mesh.philly2600.net/?p=54). Note that the version of cjdns compiled here is v17, whereas the OpenWrt package management installs v16. The benchmark results are far superior to the previous OpenWrt results, but 14 Mbps is still less than exciting.

```
Benchmark salsa20/poly1305 in 87091ms. 13778 kilobits per second
Benchmark Switching in 102578ms. 9982 packets per second
```

The only other cjdns benchmarking result on the Pi that I managed to find is [here](https://github.com/hyperboria/cjdns/blob/cc897b21cbe2606dc792e775cb17b70ef9deddef/doc/benchmark.txt#L1569). It does not seem to be inline with our results. Compiling with `NO_TEST=1 Seccomp_NO=1 CFLAGS="-march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" ./do` don't seem to make much performance difference.

Lastly, I compared OpenSSL performance between the Pi 2 and my laptop with:

```
sudo apt-get install openssl-util
openssl speed sha256 sha512 rsa1024 rsa2048
```

**Pi 2**

```
OpenSSL 1.0.1k 8 Jan 2015
built on: Fri Dec  4 10:35:13 2015
options:bn(64,32) rc4(ptr,char) des(idx,cisc,16,long) aes(partial) blowfish(ptr)
compiler: -I. -I.. -I../include  -fPIC -DOPENSSL_PIC -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -DL_ENDIAN -DTERMIO -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2 -Wl,-z,relro -Wa,--noexecstack -Wall -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DAES_ASM -DGHASH_ASM
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes
sha256            4881.48k    11410.47k    19663.96k    24067.75k    25761.11k
sha512            1520.05k     6062.83k     8584.53k    11670.19k    13041.66k
                  sign    verify    sign/s verify/s
rsa 1024 bits 0.006892s 0.000384s    145.1   2602.3
rsa 2048 bits 0.045799s 0.001408s     21.8    710.4
```

**Laptop**

```
OpenSSL 0.9.8zc 15 Oct 2014
built on: Nov 12 2014
options:bn(64,64) md2(int) rc4(ptr,char) des(idx,cisc,16,int) aes(partial) blowfish(idx)
compiler: -arch x86_64 -fmessage-length=0 -pipe -Wno-trigraphs -fpascal-strings -fasm-blocks -O3 -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -DL_ENDIAN -DMD32_REG_T=int -DOPENSSL_NO_IDEA -DOPENSSL_PIC -DOPENSSL_THREADS -DZLIB -mmacosx-version-min=10.6
available timing options: TIMEB USE_TOD HZ=100 [sysconf value]
timing function used: getrusage
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes
sha256           28698.58k    64950.82k   120827.35k   151335.36k   168763.26k
sha512           20699.47k    82632.81k   149981.62k   225291.02k   258641.05k
                  sign    verify    sign/s verify/s
rsa 1024 bits 0.000568s 0.000027s   1759.1  36716.6
rsa 2048 bits 0.002942s 0.000077s    340.0  12992.7
```