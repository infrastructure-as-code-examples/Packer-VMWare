#!/bin/bash

set -euo pipefail

# -----------------------------------------------------------------------------
# If a set environment variables shell file exists then we're probably running
# locally.  If it doesn't exist then the environment must have been
# preconfigured as would be the case if we were running on a CI/CD server.
# -----------------------------------------------------------------------------
if [ -f ./environment/vmware_centos.sh ]; then
  . ./environment/vmware_centos.sh
fi

# -----------------------------------------------------------------------------
# Populate Environment-Specific Values in Installation Preseed File
# -----------------------------------------------------------------------------
sed "s/ROOT_PASSWORD_PLACEHOLDER/$ROOT_PASSWORD/g" boot/centos_preseed_template.cfg > boot/centos_preseed.cfg

if [[ $(uname -s) == 'Linux' ]]; then
  sed -i "s/USERNAME_PLACEHOLDER/$ssh_username/g" boot/centos_preseed.cfg
  sed -i "s/PASSWORD_PLACEHOLDER/$ssh_password/g" boot/centos_preseed.cfg
  sed -i "s/GROUP_PLACEHOLDER/$ssh_usergroup/g" boot/centos_preseed.cfg
else
  # Mac :-(  Still better than Powershell or MSDOS Command Prompt
  sed -i '' "s/USERNAME_PLACEHOLDER/$ssh_username/g" boot/centos_preseed.cfg
  sed -i '' "s/PASSWORD_PLACEHOLDER/$ssh_password/g" boot/centos_preseed.cfg
  sed -i '' "s/GROUP_PLACEHOLDER/$ssh_usergroup/g" boot/centos_preseed.cfg
fi


# *****************************************************************************
# Build Image
# *****************************************************************************
packer build -only=vmware-iso templates/centos_base.json

echo "Sleeping to provide time for VMware to realize that the virtual machine has stopped."
sleep 60

# -----------------------------------------------------------------------------
# Mark VM as Template
# -----------------------------------------------------------------------------
$VMTEMPLATE_PL --url https://$vcenter_host:443/sdk/webService --username $vcenter_user --password $vcenter_pass --vmname $vmname --operation T

# -----------------------------------------------------------------------------
# Clean-up Environment-Specific Files
# -----------------------------------------------------------------------------
rm boot/centos_preseed.cfg
