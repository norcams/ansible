#!/bin/bash

# print help
function usage {
  echo ""
  echo "This will reinstall an el8 compute host with el9 AND a new name"
  echo "You will need the HOSTNAME (not FQDN) of the host"
  echo "./${0} <location-compute-old_number> <location-compute-new_number>"
  echo ""
  exit 1
}

if ! [[ ${1} =~ ^[A-Za-z0-9._]+[-]+["compute"]+[-]+[A-Za-z0-9._] ]]; then
  echo "Usage:"
  echo "You will need the compute HOSTNAME (not FQDN) of the host"
  echo "./${0} <location-compute-old_number> <location-compute-new_number>"
  echo ""
  exit 1
fi

host_old=$1
host_new=$2

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

sudo ansible-playbook -e "myhosts=${host_old}" lib/check_for_running_instances.yaml || exit 1
sudo ansible-playbook -e "myhosts=${host_old}" lib/fix_uefi_bootorder.yaml # FIXME
sudo ansible-playbook -e "myhosts=${location}-proxy-02 install_host=${host_old}" lib/node_delete.yaml
sudo ansible-playbook -e "myhosts=${location}-proxy-02 sensu_expire=7200 install_host=${host_new}" lib/reinstall.yaml
sudo ansible-playbook -e "myhosts=${host_old}" lib/clean_calico_host_etcd.yaml
sudo ansible-playbook -e "myhosts=${location}-login-01" -e "host=${host_old}" lib/ssh_host_keys.yaml
sudo ansible-playbook -e "myhosts=${host_old}" -e "silence_sensu=false" lib/reboot.yaml
sleep 120
sudo ansible-playbook -e "myhosts=${host_new} name=iptables" lib/systemd_restart.yaml
sudo ansible-playbook -e "myhosts=${host_new} name=ip6tables" lib/systemd_restart.yaml
sudo ansible-playbook -e "myhosts=${host_new}" lib/puppetrun.yaml
sudo ansible-playbook -e "myhosts=${host_new}" lib/push_secrets.yaml
sudo ansible-playbook -e "myhosts=${host_new} ip_version=ipv6" lib/flush_iptables.yaml
sudo ansible-playbook -e "myhosts=${host_new}" lib/puppetrun.yaml
# Need to restart metadata api to get it to work
sudo ansible-playbook -e "myhosts=${host_new} name=openstack-nova-metadata-api.service" lib/systemd_restart.yaml
# Fix for nova missing nvram flag when rebuilding from a uefi image
sudo ansible-playbook -e "myhosts=${host_new} patchfile=../files/patches/nova-libvirt-rebuild.diff dest=/usr/lib/python3.9/site-packages/nova/virt/libvirt/guest.py" lib/patch.yaml
# Fix for newer libvirt, we need to not manage the tap interface in nova
sudo ansible-playbook -e "myhosts=${host_new} patchfile=../files/patches/nova-compute-fix-tap.diff basedir=/usr/lib/python3.9/site-packages" lib/patch.yaml
# Restart nova-compute after patching
sudo ansible-playbook -e "myhosts=${host_new} name=openstack-nova-compute.service" lib/systemd_restart.yaml
# Fix for nova missing nvram flag when rebuilding from a uefi image
# This will fix this: https://access.redhat.com/solutions/7024764
sudo ansible-playbook -e "myhosts=${host_new} name=iscsid" lib/systemd_restart.yaml
#sudo ansible-playbook -e "myhosts=${host} name=openstack-nova-compute" lib/systemd_restart.yaml
