#!/bin/bash

set -euo pipefail

# -----------------------------------------------------------------------------
# If a set environment variables shell file exists then we're probably running
# locally.  If it doesn't exist then the environment must have been
# preconfigured as would be the case if we were running on a CI/CD server.
# -----------------------------------------------------------------------------
if [ -f ./environment/vmware_windows.sh ]; then
  . ./environment/vmware_windows.sh
fi

# -----------------------------------------------------------------------------
# Populate Environment-Specific Values in Installation Answers File
# -----------------------------------------------------------------------------
sed "s/ROOT_PASSWORD_PLACEHOLDER/$ROOT_PASSWORD/g" boot/windows_autounattend_template.xml > boot/autounattend.xml

if [[ $(uname -s) == 'Linux' ]]; then
  sed -i "s/EULA_FULLNAME_PLACEHOLDER/$EULA_FULLNAME/g" boot/autounattend.xml
  sed -i "s/EULA_ORGANIZATION_PLACEHOLDER/$EULA_ORGANIZATION/g" boot/autounattend.xml
  sed -i "s/TIME_ZONE_PLACEHOLDER/$TIME_ZONE/g" boot/autounattend.xml
  sed -i "s/COMPUTERNAME_PLACEHOLDER/$vmname/g" boot/autounattend.xml
  sed -i "s/USERNAME_PLACEHOLDER/$ssh_username/g" boot/autounattend.xml
  sed -i "s/PASSWORD_PLACEHOLDER/$ssh_password/g" boot/autounattend.xml
else
  # Mac :-(  Still better than Powershell or MSDOS Command Prompt
  sed -i '' "s/EULA_FULLNAME_PLACEHOLDER/$EULA_FULLNAME/g" boot/autounattend.xml
  sed -i '' "s/EULA_ORGANIZATION_PLACEHOLDER/$EULA_ORGANIZATION/g" boot/autounattend.xml
  sed -i '' "s/TIME_ZONE_PLACEHOLDER/$TIME_ZONE/g" boot/autounattend.xml
  sed -i '' "s/COMPUTERNAME_PLACEHOLDER/$vmname/g" boot/autounattend.xml
  sed -i '' "s/USERNAME_PLACEHOLDER/$ssh_username/g" boot/autounattend.xml
  sed -i '' "s/PASSWORD_PLACEHOLDER/$ssh_password/g" boot/autounattend.xml
fi

# -----------------------------------------------------------------------------
# Populate Environment-Specific Values in Floppy-Mounted Script
# -----------------------------------------------------------------------------
sed "s/USERNAME_PLACEHOLDER/$ssh_username/g" scripts/windows/floppy/install_openssh_template.ps1 > scripts/windows/floppy/install_openssh.ps1

# *****************************************************************************
# Build Image
# *****************************************************************************
packer build -on-error=abort -only=vmware-iso templates/windows_base.json

echo "Sleeping to provide time for VMware to realize that the virtual machine has stopped."
sleep 60

# -----------------------------------------------------------------------------
# Mark VM as Template
# -----------------------------------------------------------------------------
$VMTEMPLATE_PL --url https://$vcenter_host:443/sdk/webService --username $vcenter_user --password $vcenter_pass --vmname $vmname --operation T

# -----------------------------------------------------------------------------
# Clean-up Environment-Specific Files
# -----------------------------------------------------------------------------
rm boot/autounattend.xml
rm scripts/windows/floppy/install_openssh.xml
