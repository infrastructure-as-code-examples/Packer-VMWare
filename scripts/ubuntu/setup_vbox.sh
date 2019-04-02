#!/bin/bash -eux

# -----------------------------------------------------------------------------
# Install the VirtualBox guest additions
# -----------------------------------------------------------------------------
# If this isn't done then Terraform won't be able to access the assined IP
# address (or other guest properties) via VBoxManage guestproperty and,
# as a result, won't know that the process was successful.
# -----------------------------------------------------------------------------
VBOX_VERSION=$(cat /home/packer/.vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop $VBOX_ISO /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm $VBOX_ISO

# -----------------------------------------------------------------------------
# Update Network Interface Reference for Terraform Build
# -----------------------------------------------------------------------------
# Packer automatically provisions a NAT adapter as part of its process. In my
# version of VirtualBox (5.2.0) this leaves an entry in the interfaces file
# called enp0s3.  For whatever reason when Terraform configures a Bridged
# adapter, also in the first slot, the name given to it is consistently
# enp0s17. For ease of Terraform initialization I am simply replacing the
# reference to enp0s03 with enp0s17.  In reality, this would be better done as
# part of the Terraform process.  Unfortunately, I haven't been able to find a
# way to accomplish this since Terraform would need to be able to connect to
# the machine after it spins up to be able to update the interfaces file;
# basically a "chicken and egg problem".  I would dig into this a little more
# but I think the issue is specific to VirtualBox, which wouldn't be used in a
# real-world server scenario.  Basically, digging into it deeper isn't worth
# the effort.
# -----------------------------------------------------------------------------
sed -i 's/enp0s3/enp0s17/g' /etc/network/interfaces
