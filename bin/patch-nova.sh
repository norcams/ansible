#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to patch nova for CVE-2022-47951"
  echo "bin/patch-nova.sh <location>-novactrlcompute-01"
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/nova-fix-CVE-2022-47951.diff basedir=/usr/lib/python3.6/site-packages" lib/patch.yaml
sudo ansible-playbook -e "myhosts=${host} name=openstack-nova-api" lib/systemd_restart.yaml
