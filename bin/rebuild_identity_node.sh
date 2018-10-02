#!/bin/bash
set -e

# print help
function usage {
  echo ""
  echo "This will rebuild a node."
  echo "You will need the HOSTNAME (not FQDN) of the node being reinstalled"
  echo "./${0} <hostname>>"
  echo ""
  exit 1
}

host=$1

# Use hostname not fqdn
if [[ $host == *.* ]] ; then
  usage
fi

IFS='-' read -r -a hostname <<< "$host"
location=${hostname[0]}

read -p "This will rebuild ${host}. Are you sure? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi
echo

sudo ansible-playbook -e "myhosts=${location}-proxy-01 install_host=${host}" lib/reinstall.yaml
sleep 120
sudo ansible-playbook -e "myhosts=${host}" lib/setup_identity.yaml
