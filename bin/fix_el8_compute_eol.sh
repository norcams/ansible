#!/bin/bash

# print help
function usage {
  echo ""
  echo "This will patch an old el8 compute so we can migrate to a new el9"
  echo "You will need the HOSTNAME (not FQDN) of the host"
  echo "./${0} <location-compute-number>"
  echo ""
  exit 1
}

if ! [[ ${1} =~ ^[A-Za-z0-9._]+[-]+["compute"]+[-]+[A-Za-z0-9._] ]]; then
  echo "Usage:"
  echo "You will need the compute HOSTNAME (not FQDN) of the host"
  echo "./${0} <location-compute-number>"
  echo ""
  exit 1
fi

host=$1

# Fix for libvirt, we need to not manage the tap interface in nova before we migrate to el9
sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/nova-compute-fix-tap.diff basedir=/usr/lib/python3.6/site-packages" lib/patch.yaml
# Restart nova-compute after patching
sudo ansible-playbook -e "myhosts=${host} name=openstack-nova-compute.service" lib/systemd_restart.yaml
