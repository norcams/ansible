#!/bin/bash

# print help
function usage {
  echo ""
  echo "This will rebuild a compute host."
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

# Use hostname not fqdn
if [[ $host == *.* ]] ; then
  usage
fi

IFS='-' read -r -a hostname <<< "$host"
location=${hostname[0]}

read -p "Are your sure you want to rebuild ${host}? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi
echo

sudo ansible-playbook -e "myhosts=${host}" lib/check_for_running_instances.yaml || exit 1
sudo ansible-playbook -e "myhosts=${host}" lib/fix_uefi_bootorder.yaml # FIXME
sudo ansible-playbook -e "myhosts=${location}-proxy-02 sensu_expire=7200 install_host=${host}" lib/reinstall.yaml
sudo ansible-playbook -e "myhosts=${host}" lib/clean_calico_host_etcd.yaml
sudo ansible-playbook -e "myhosts=${location}-login-01" -e "host=${host}" lib/ssh_host_keys.yaml
sudo ansible-playbook -e "myhosts=${host}" -e "silence_sensu=false" lib/reboot.yaml
sleep 120
sudo ansible-playbook -e "myhosts=${host} name=iptables" lib/systemd_restart.yaml
sudo ansible-playbook -e "myhosts=${host} name=ip6tables" lib/systemd_restart.yaml
sudo ansible-playbook -e "myhosts=${host}" lib/puppetrun.yaml
sudo ansible-playbook -e "myhosts=${host}" lib/push_secrets.yaml
sudo ansible-playbook -e "myhosts=${host} ip_version=ipv6" lib/flush_iptables.yaml
sudo ansible-playbook -e "myhosts=${host}" lib/puppetrun.yaml
# Need to restart metadata api to get it to work
sudo ansible-playbook -e "myhosts=${host} name=openstack-nova-metadata-api.service" lib/systemd_restart.yaml
# Fix for nova missing nvram flag when rebuilding from a uefi image
sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/nova-libvirt-rebuild.diff dest=/usr/lib/python3.9/site-packages/nova/virt/libvirt/guest.py" lib/patch.yaml
# Fix for newer libvirt, we need to not manage the tap interface in nova
sudo ansible-playbook -e "myhosts=${host} patchfile=../files/patches/nova-compute-fix-tap.diff basedir=/usr/lib/python3.9/site-packages" lib/patch.yaml
# Restart nova-compute after patching
sudo ansible-playbook -e "myhosts=${host} name=openstack-nova-compute.service" lib/systemd_restart.yaml
# Fix for nova missing nvram flag when rebuilding from a uefi image
# This will fix this: https://access.redhat.com/solutions/7024764
sudo ansible-playbook -e "myhosts=${host} name=iscsid" lib/systemd_restart.yaml
#sudo ansible-playbook -e "myhosts=${host} name=openstack-nova-compute" lib/systemd_restart.yaml
