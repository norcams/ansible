#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to patch cinder for CVE-2022-47951"
  echo "bin/patch-cinder.sh <location>-volume-01"
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/cinder-fix-CVE-2022-47951.diff basedir=/usr/lib/python3.6/site-packages" lib/patch.yaml
sudo ansible-playbook -e "myhosts=${host} name=openstack-cinder-volume" lib/systemd_restart.yaml
sudo ansible-playbook -e "myhosts=${host} name=openstack-cinder-scheduler" lib/systemd_restart.yaml
