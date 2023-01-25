#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to patch glance for CVE-2022-47951"
  echo "bin/patch-glance.sh <location>-image-01"
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/glance-fix-CVE-2022-47951.diff basedir=/usr/lib/python3.6/site-packages" lib/patch.yaml
sudo ansible-playbook -e "myhosts=${host} name=openstack-glance-api" lib/systemd_restart.yaml

# openstack-glance-api.service           enabled
# openstack-glance-registry.service      disabled
# openstack-glance-scrubber.service      disabled
