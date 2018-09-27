#!/bin/bash

# print help
function usage {
  echo
  echo 'Run this script to delete DNS records listed in group_vars'
  echo 'USAGE:'
  echo '  bin/delete_dns_records.sh <location>'
  echo
  exit 1
}

LOC=$1

if [ $# -ne 1 ]; then
  usage
fi

echo "====> Running playbook: lib/delete_dns_records.yaml"
sudo ansible-playbook -e "myhosts=${LOC}-admin-01" lib/delete_dns_records.yaml
