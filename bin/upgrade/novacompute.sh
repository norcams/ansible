#!/bin/bash

function usage {
  echo ""
  echo "This will upgrade novactrl in a location, including deps"
  echo "./${0} <HOSTNAME> --<opt>"
  echo "Example: ./${0} test01-compute-01 --check"
  echo ""
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

host=$1

# Use hostname not fqdn
if [[ $host == *.* ]] ; then
  usage
fi

if [ -z $2 ]; then
  opt=""
else
  opt="$2"
fi

sudo ansible-playbook $opt -e "hosts=${host}" lib/upgrade/compute.yaml
sudo ansible-playbook $opt -e "hosts=${host} patchfile=${HOME}/ansible/files/patches/python-nova-newton-centos-7.3.0-discard.diff dest=/usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.py" lib/patch.yaml
sudo ansible-playbook $opt -e "hosts=${host} name=openstack-nova-compute.service" lib/systemd_restart.yaml
