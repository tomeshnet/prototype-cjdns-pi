# Installing Armbian on Orange Pi, NanoPi, Rock64, EspressoBin

_Not all variants of boards have been tested, this does not mean it will not work. If you have an unlisted board that works, please let us know._

1. Make sure you have the following items:

    * Armbian-compatible board
    * SD card

1. Flash the SD card with the appropriate Armbian image (usually the Nightly for your board, refer to [Hardware Table](README.md#hardware-table)).

1. Plug the SD card and USB WiFi adapter (if applicable) into the board.

1. Plug the board into your router, so it has connectivity to the Internet.

1. SSH into the board with the username **root** and password **1234**.

1. When prompted, enter the password **1234** again.

1. When prompted, enter a _new_ password, this will be your new root password.

1. When prompted, enter your _new_ password again.

1. When prompted, enter a non-root username for your board.

1. When prompted, enter a password for your new non-root user.

1. Answer the rest of the prompts about the new non-root user, or simply press enter at each prompt to skip.

1. Continue with [Prototype Installation](README.md).
