#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


mkdir /tmp/babeld
mkdir /tmp/babeld/root
mkdir /tmp/babeld/src


cp -R $BASE_DIR/files /tmp/babeld/root

last=`pwd`
git clone git://github.com/jech/babeld.git /tmp/babeld/src
cd /tmp/babeld/src
sed -i 's|PREFIX = /usr/local|PREFIX = /tmp/babeld/root|' Makefile
make
make install
cd $last
