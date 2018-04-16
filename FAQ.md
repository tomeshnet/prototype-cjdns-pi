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
echo enable_uart=1  dtoverlay=pi3-disable-bt
```

**Note:** U-boot will not appear on serial, only once kernel starts to boot do you see output


## Orange Pi

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

**A:** Manual flashing to latest u-boot is mandatory! [Download](https://dl.armbian.com/espressobin/u-boot/) the right boot flash for your board: 512,1G,2G, number of RAM chips (one at the bottom or 2 one on each side of the board) and appropirate memory speeds. You can obtain numbers from current boot prompt.  Copy this flash-image-MEM-RAM_CHIPS-CPU_DDR_boot_sd_and_usb.bin to your FAT formatted USB key, plug it into USB3.0 port and execute from u-boot prompt: 
```
bubt flash-image-MEM-CPU_DDR_boot_sd_and_usb.bin spi usb
```

**Q:** How do I boot Armbian on an EspressoBin from an sd card?

**A:** First update the u-boot (above). Then run the following in u-boot.
```
setenv initrd_addr 0x1100000
setenv image_name boot/Image
setenv load_script 'if test -e mmc 0:1 boot/boot.scr; then echo \"... booting from SD\";setenv boot_interface mmc;else echo \"... booting from USB/SATA\";usb start;setenv boot_interface usb;fi;if test -e \$boot_interface 0:1 boot/boot.scr;then ext4load \$boot_interface 0:1 0x00800000 boot/boot.scr; source; fi'
setenv bootcmd 'run get_images; run set_bootargs; run load_script;booti \$kernel_addr \$ramfs_addr \$fdt_addr'
saveenv
```
