#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to patch glance for CVE-2022-47951"
  echo "bin/patch-glance.sh <location>-image-01"
  echo ""
  echo "Only needed if"
  echo "[image_import_opts]"
  echo "image_import_plugins = ['image_conversion']"
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/glance-fix-CVE-2022-47951.diff basedir=/usr/lib/python3.6/site-packages" lib/patch.yaml

sudo ansible ${host} -o -m file -a "name=/usr/lib/python3.6/site-packages/glance/async_/flows/plugins/__pycache__/image_conversion.cpython-36.pyc state=absent"
sudo ansible ${host} -o -m file -a "name=/usr/lib/python3.6/site-packages/glance/async_/flows/plugins/__pycache__/image_conversion.cpython-36.opt-1.pyc state=absent"
sudo ansible ${host} -o -m file -a "name=/usr/lib/python3.6/site-packages/glance/common/__pycache__/config.cpython-36.pyc state=absent"
sudo ansible ${host} -o -m file -a "name=/usr/lib/python3.6/site-packages/glance/common/__pycache__/config.cpython-36.opt-1.pyc state=absent"

sudo ansible ${host} -o -a "python3 -m compileall /usr/lib/python3.6/site-packages/glance/async_/flows/plugins/"
sudo ansible ${host} -o -a "python3 -m compileall /usr/lib/python3.6/site-packages/glance/common/"

sudo ansible-playbook -e "myhosts=${host} name=openstack-glance-api" lib/systemd_restart.yaml
