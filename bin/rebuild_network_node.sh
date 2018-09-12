#!/bin/bash
set -e

# print help
function usage {
  echo ""
  echo "This will rebuild a network node."
  echo "You will need the HOSTNAME (not FQDN) of the node being reinstalled"
  echo "and the HOSTNAME from another node who will manage the cluster."
  echo "./${0} <location-network-number> <location-network-number>"
  echo ""
  exit 1
}

host=$1
manage_from=$2

# Use hostname not fqdn
if [[ $host == *.* ]] ; then
  usage
fi

IFS='-' read -r -a hostname <<< "$host"
location=${hostname[0]}

read -p "This will rebuild ${host} and manage the etcd cluster from ${manage_from}. Are you sure? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi
echo

sudo ansible-playbook -e "myhosts=${location}-proxy-01 install_host=${host}" lib/reinstall.yaml
sleep 120
sudo ansible-playbook -e "myhosts=${host}" lib/puppetrun.yaml
sudo ansible-playbook -e "myhosts=${host}" lib/puppetrun.yaml
sudo ansible-playbook -e "member=${host} manage_from=${manage_from}" lib/reconfigure_etcd_cluster.yaml
