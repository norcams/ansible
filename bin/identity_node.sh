#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this to set up a new identity node."
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host}" lib/push_gpg_keys.yaml
sudo ansible-playbook -e "myhosts=${host}" lib/identity_node.yaml