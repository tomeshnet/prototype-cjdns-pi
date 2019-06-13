#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prep working directory
mkdir /tmp/babeld
mkdir /tmp/babeld/root
mkdir /tmp/babeld/src

# Prepare root directory
cp -R $BASE_DIR/files/* /tmp/babeld/root/

# Compile babeld and install babeld into root directory
last=`pwd`
git clone git://github.com/jech/babeld.git /tmp/babeld/src
cd /tmp/babeld/src
sed -i 's|PREFIX = /usr/local|PREFIX = /tmp/babeld/root|' Makefile
make
make install
cd ..

# Make deb pacakges
version="$(root/bin/babeld -V 2>&1)"
version=${version:7}
echo "Version: $version" >> root/DEBIAN/control
echo "Architecture: $(dpkg --print-architecture)" >> root/DEBIAN/control
dpkg-deb --build root

# Install and cleanup
sudo dpkg -i /tmp/babeld/root.deb
rm -rf /tmp/babeld
