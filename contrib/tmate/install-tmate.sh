#!/bin/sh
wget https://github.com/tmate-io/tmate/releases/download/2.2.1/tmate-2.2.1-static-linux-armv7l.tar.gz
tar xvfz tmate-2.2.1-static-linux-armv7l.tar.gz
sudo mv tmate-2.2.1-static-linux-armv7l/tmate /usr/local/bin
rm -rf tmate-2.2.1-static-linux-armv7l
ssh-keygen
