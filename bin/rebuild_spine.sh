#!/bin/bash

# print help
function usage {
  echo ""
  echo "This will rebuild a spine, torack or leaf host."
  echo "You will need the HOSTNAME (not FQDN) of the host."
  echo "./${0} <location-spine|torack|leaf-number>"
  echo " "
  echo "*** WARNING ***"
  echo "Ensure that the mgmt IP is registered in the admin role with a fixed IP address!"
  echo "Ensure that the mgmt IP is registered in DNS with reverse lookup!"
  echo "Ensure that redundant connection is available for every connected host!"
  echo " "
  echo "You can not rebuild mgmt switches with this job!"
  exit 1
}

if ! [[ ${1} =~ ^[A-Za-z0-9._]+[-]+["compute"]+[-]+[A-Za-z0-9._] ]]; then
  echo "Usage:"
  echo "You will need the spine HOSTNAME (not FQDN) of the host"
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

sudo ansible-playbook -e "myhosts=${location}-proxy-02 sensu_expire=7200 install_host=${host}" lib/delete_host.yaml
sudo ansible -u iaas -a '/usr/cumulus/bin/onie-select -i -f' -m shell ${host}
sudo ansible-playbook -e "myhosts=${host}" lib/reboot.yaml
