# Frequently Asked Questions

## Raspberry Pi

**Q:** Can I connect a serial cable (TTL) to a Raspberry Pi (or Rock64)?

**A:** Yes, there are TTL pins in the GPIO pins. They are as follows  
```
VCC → RPi Pin 02 (5V)
GND → RPi Pin 06
RXD → RPi Pin 08
TXD → RPi Pin 10
```

You will also need to configure Rasbian to output information on these pins.  To do so add this to your **config.txt** file located on your **boot** partition.
```
enable_uart=1 dtoverlay=pi3-disable-bt
```

**Note:** U-boot will not appear on serial, only once kernel starts to boot do you see output


## Armbian Boards

**Q:** What are the instructions to install an Armbian?

**A**: Install the OS and prepare the board as follows.

1. Make sure you have the following items:

    * Armbian-compatible board
    * SD card

1. Flash the SD card with the appropriate Armbian image (usually the Nightly for your board, refer to [Hardware Table](README.md#hardware-table)).

1. Plug the SD card into the board.

1. Plug the board into your router, so it has connectivity to the Internet.

1. SSH into the board with the username **root** and password **1234**. Default hostnames are similar to your boards name. For example **orangepizero** for an Orange Pi Zero **espressobin** for an Espressobin etc.

1. When prompted, enter the password **1234** again.

1. When prompted, enter a _new_ password, this will be your new root password.

1. When prompted, enter your _new_ password again.

1. When prompted, enter a non-root username for your board.

1. When prompted, enter a password for your new non-root user.

1. When prompted, enter the password for the non-root user again.

1. Answer the rest of the prompts about the new non-root user, or simply press enter at each prompt to skip.

1. Continue with [Prototype Installation](README.md).

**Q:** Why do my Orange Pi Zero USB headers not work?

**A:** Some images are missing the USB overlay.  Simply add the following to the **/boot/armbianEnv.txt** file and restart the Pi.
```
overlays=usbhost2 usbhost3
```

**Q:** Why do I get an error about a locked file when I try to install the node on an Orange Pi?

**A**: The daily apt upgrade sometimes starts up in the background locking the apt database. This will cause the script to fail as it tries to install the required software. Wait for the upgrade to finish.

**Q:** Seems all my mac addresses are the same across multiple boards. How do I fix this?

Seems some of the Armbian images have a hardcoded machine id.  Generate a new one using the following script 
```
if [ `cat /etc/machine-id` == "f3f0aa4383b442e6ae0b889a10144d76" ]; then  
    echo Generating new ID
    sudo mv /etc/machine-id /etc/machine-id.old
    dbus-uuidgen | sudo tee /var/lib/dbus/machine-id
    sudo cp /var/lib/dbus/machine-id /etc/machine-id
fi
```

### Rock64

**Q:** What is the baud rate for the Rock64?

**A:** U-boot baud rate seems to be 1500000. Once ubuntu starts it is 115200

### ESPRESSObin

**Q:** How do I upgrade the U-boot on Espressobin?

**A:** Manual flashing to latest U-boot is mandatory! [Download](https://dl.armbian.com/espressobin/u-boot/) the right boot flash for your board: 512,1G,2G, number of RAM chips (one at the bottom or 2 one on each side of the board) and appropirate memory speeds. You can obtain numbers from current boot prompt.  Copy this flash-image-MEM-RAM_CHIPS-CPU_DDR_boot_sd_and_usb.bin to your FAT formatted USB key, plug it into USB3.0 port and execute from U-boot prompt: 
```
bubt flash-image-MEM-CPU_DDR_boot_sd_and_usb.bin spi usb
```

**Q:** How do I boot Armbian on an Espressobin from an sd card?

**A:** First update the U-boot (above). Then run the following in U-boot.
```
setenv initrd_addr 0x1100000
setenv image_name boot/Image
setenv load_script 'if test -e mmc 0:1 boot/boot.scr; then echo \"... booting from SD\";setenv boot_interface mmc;else echo \"... booting from USB/SATA\";usb start;setenv boot_interface usb;fi;if test -e \$boot_interface 0:1 boot/boot.scr;then ext4load \$boot_interface 0:1 0x00800000 boot/boot.scr; source; fi'
setenv bootcmd 'run get_images; run set_bootargs; run load_script;booti \$kernel_addr \$ramfs_addr \$fdt_addr'
saveenv
```
## Wireless

**Q:** Why do my MeshPoint/AdHoc nodes on v0.3 or lower no longer mesh with v0.4 or higher?

**A:** We dropped the band width of MeshPoint and AdHoc to 20MHz from 40MHz in v0.4. This should provide a bit better responsiveness in urban environments.  Unfortunately the 20MHz and 40MHz bands do not work together.

You can update your v0.3 or lower nodes to use 20MHz by editing the `/usr/bin/mesh-adhoc` or `/usr/bin/mesh-point` file and removing the HT40+ paramater from the iw line near the bottom of the file, then simply reboot.

**Q:** Can I use the on board wireless of my RaspberryPi/OrangePi/etc to mesh?

**A:** Maybe. 

On board wireless we have seen so far
* Do NOT support 802.11s/meshpoint
* Do report to support Ad-Hoc mode 
* Do NOT support 40Mhz width
* Will only connect to other devices using Ad-Hoc and not using 40Mhz
* May or may not work. Protocol is not usually maintained as part of drivers

To install
* Install Ad-Hoc mesh module
* Do NOT install Access Point

If you have success using ad-hoc with on board cards please let us know your experience.

So far:
- 3b+ seemed to have worked but 3b did not
- 3b working by killing wpa_supplicant first
