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
**Note:** U-boot will not appear on serial, only once kernel starts to boot do you see output

## Armbian

**Q:** What are the instructions to install an Armbian?

**A**: Install the OS and prepare the board as follows.

1. Make sure you have the following items:

    * Armbian-compatible board
    * SD card

1. Flash the SD card with the appropriate Armbian image (usually the Nightly for your board, refer to [Hardware Table](README.md#hardware-table)).

1. Plug the SD card into the board.

1. Plug the board into your router, so it has connectivity to the Internet.

1. SSH into the board with the username **root** and password **1234**. Default hostnames are similar to your boards name. For example **ornagepizero** for an Orange Pi Zero **expressobin** for an expresso bin etc.

1. When prompted, enter the password **1234** again.

1. When prompted, enter a _new_ password, this will be your new root password.

1. When prompted, enter your _new_ password again.

1. When prompted, enter a non-root username for your board.

1. When prompted, enter a password for your new non-root user.

1. Answer the rest of the prompts about the new non-root user, or simply press enter at each prompt to skip.

1. Continue with [Prototype Installation](README.md).

**Q:** Why do my Orange Pi Zero USB headers not work?

**A:** Some images are missing the USB overlay.  Simply add the following to the **/boot/armbianEnv.txt** file and restart the Pi.
```
overlays=usbhost2 usbhost3
```

**Q:** Why do I get an error about a locked file when I try to install the node on an Orange Pi?

**A**: The daily apt upgrade sometimes starts up in the background locking the apt database. This will cause the script to fail as it tries to install the required software. Wait for the upgrade to finish.

## Rock64

**Q:** What is the baud rate for the Rock64?

**A:** U-boot baud rate seems to be 1500000. Once ubuntu starts it is 115200

## EspressoBin

**Q:** How do I upgrade the U-boot on EspressoBin?

**A:** Manual flashing to latest u-boot is mandatory! [Download](https://dl.armbian.com/espressobin/u-boot/) the right boot flash for your board: 512,1G,2G and appropriate memory speeds. You can obtain numbers from current boot prompt. Copy this flash-image-MEM-CPU_DDR_boot_sd_and_usb.bin to your FAT formatted USB key, plug it into USB3.0 port and execute from u-boot prompt: 
```
bubt flash-image-MEM-CPU_DDR_boot_sd_and_usb.bin spi usb
```

**Q:** How do I boot Armbian on an EspressoBin from an sd card?

**A:** First update the u-boot (above). Then run the following in u-boot.
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
