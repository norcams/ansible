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

sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/nova-fix-CVE-2022-47951.diff basedir=/usr/lib/python3.6/site-packages" lib/patch.yaml

sudo ansible ${host} -m file -a "name=/usr/lib/python3.6/site-packages/nova/conf/__pycache__/compute.cpython-36.pyc state=absent"
sudo ansible ${host} -m file -a "name=/usr/lib/python3.6/site-packages/nova/virt/__pycache__/images.cpython-36.pyc state=absent"
sudo ansible ${host} -a "python3 -m compileall /usr/lib/python3.6/site-packages/nova/virt/"
sudo ansible ${host} -a "python3 -m compileall /usr/lib/python3.6/site-packages/nova/conf/"

sudo ansible-playbook -e "myhosts=${host}" lib/restart_compute_services.yaml
