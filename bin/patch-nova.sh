#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to patch nova for CVE-2022-47951"
  echo "bin/patch-nova.sh <location>-compute-01"
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host}" lib/patch_nova_cve_2022_47951.yaml

sudo ansible ${host} -o -m systemd -a "name=openstack-nova-compute state=restarted"
sleep 20
sudo ansible ${host} -o -m systemd -a "name=openstack-nova-metadata-api state=restarted"
