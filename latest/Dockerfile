FROM resin/rpi-raspbian:latest

COPY qemu-arm-static /usr/bin/qemu-arm-static
RUN  apt-get update \
  && apt-get install -y wget