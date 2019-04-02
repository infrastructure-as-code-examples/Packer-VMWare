#!/bin/bash -eux

echo "Installing VMware Tools"
yum -y install open-vm-tools perl
systemctl start vmtoolsd.service
systemctl enable vmtoolsd.service
