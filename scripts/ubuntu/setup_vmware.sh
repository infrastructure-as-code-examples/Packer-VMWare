#!/bin/bash -eux

echo "Installing VMware Tools guest additions"
apt-get install -y linux-headers-$(uname -r) build-essential perl
apt-get install -y dkms
apt-get install -y open-vm-tools open-vm-tools-dkms
apt-get -y remove linux-headers-$(uname -r) build-essential perl
apt-get -y autoremove
