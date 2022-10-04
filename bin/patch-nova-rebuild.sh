#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to fix the rebuild issue in Nova"
  echo "When rebuilding from an UEFI image to a non-UEFI image, nova does not"
  echo "add the proper 'nvram' flag to get the old instance removed."
  echo "This patch adds the flag regardless of the type of image."
  echo
  echo "bin/patch-nova-rebuild.sh <location>-compute-01"
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host} patchfile=${HOME}/ansible/files/patches/nova-libvirt-rebuild.diff dest=/usr/lib/python3.6/site-packages/nova/virt/libvirt/guest.py" lib/patch.yaml
sudo ansible-playbook -e "myhosts=${host} name=openstack-nova-compute" lib/systemd_restart.yaml
