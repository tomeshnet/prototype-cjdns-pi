#!/bin/sh

wget https://github.com/tmate-io/tmate/releases/download/2.2.1/tmate-2.2.1-static-linux-armv7l.tar.gz
tar xvfz tmate-2.2.1-static-linux-armv7l.tar.gz -C /tmp
sudo mv /tmp/tmate-2.2.1-static-linux-armv7l/tmate /usr/local/bin
rm -rf /tmp/tmate-2.2.1-static-linux-armv7l

# Generate RSA key pair for tmate SSH session
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
