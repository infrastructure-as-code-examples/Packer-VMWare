#!/bin/bash -eux

# yum clean-up
yum clean all
rm -rf /var/cache/yum

# Zero out the rest of the free space using dd, then delete the written file.
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Ensures Packer doesn't quit before the large file is deleted.
sync
