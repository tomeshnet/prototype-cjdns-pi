# Installing Base OS on Armbian (Orange Pi, NanoPi, etc)

Notes that all variants of boards have NOT been tested, this does not mean it will not work.  If you have a board that is not listed that works please let us know.

1. Make sure you have the following items
    * Armbian compatible board
    * SD Card that works with the PI
     * **Optional:** A USB WiFi adapter with [802.11s Mesh Point](https://github.com/o11s/open80211s/wiki/HOWTO) support, such as the [TP-LINK TL-WN722N](http://www.tp-link.com/en/products/details/TL-WN722N.html) or [Toplinkst TOP-GS07](https://github.com/tomeshnet/documents/blob/master/technical/20170208_mesh-point-with-topgs07-rt5572.md)

1. Flash the SD card with Armbian Nightly

1. Plug the SD card and USB WiFi adapter into the Pi

1. Plug the Pi into your router, so it has connectivity to the Internet. SSH into the Pi with the **root** username and password **1234**.

1. When prompted enter the password **1234** again.

1. Enter a NEW password

1. Enter your NEW password again

1. Select and enter a non-root username for your pi 

1. Enter a password for your new user

1. Fill in the remainder of the information or simply skip by pressing enter

1. Continue with [Prototype Installation](README.md) 
