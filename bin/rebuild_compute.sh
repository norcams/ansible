#!/bin/bash

# print help
function usage {
  echo ""
  echo "This will rebuild a compute host."
  echo "You will need the HOSTNAME (not FQDN) of the host"
  echo "./${0} <HOSTNAME> --force"
  exit 1
}

if [ $# -ne 2 ]; then
  usage
fi

if [ "${2}" != '--force' ]; then
  usage
fi
host=$1

# Use hostname not fqdn
if [[ $host == *.* ]] ; then
  usage
fi

IFS='-' read -r -a hostname <<< "$host"
location=${hostname[0]}

sudo ansible-playbook -e "hosts=${location}-proxy-01 compute_host=${host}" lib/prepare_compute_reinstall.yaml
sudo ansible-playbook -e "hosts=${host}" lib/reboot.yaml
sudo ansible-playbook -e "hosts=${location}-login host=${host}" lib/ssh_host_keys.yaml
sleep 120
sudo ansible-playbook -e "hosts=${host}" lib/puppetrun.yaml
sudo ansible-playbook -e "hosts=${host}" lib/push_secrets.yaml
sudo ansible-playbook -e "hosts=${host}" lib/puppetrun.yaml
sudo ansible-playbook -e "hosts=${host} patchfile=${HOME}/ansible/files/patches/python-nova-newton-centos-7.3.0-discard.diff dest=/usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.py" lib/patch.yaml
sudo ansible-playbook -e "hosts=${host}" lib/downgrade_neutron.yaml
sudo ansible-playbook -e "hosts=${host} name=openstack-nova-compute.service" lib/systemd_restart.yaml
