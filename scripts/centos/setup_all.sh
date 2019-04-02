#!/bin/bash -eux

# configure sudo
echo "$ssh_username        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers

# update all packages
yum update -y

# install temporary packages
yum install -y wget

# update certificates
wget --no-check-certificate -O /etc/pki/tls/certs/ca-bundle.crt http://curl.haxx.se/ca/cacert.pem

# remove temporary packages
yum remove -y wget
