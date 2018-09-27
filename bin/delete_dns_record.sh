#!/bin/bash

# print help
function usage {
  echo
  echo 'Run this script to delete DNS records listed in group_vars'
  echo 'USAGE:'
  echo '  bin/delete_dns_records.sh <location> <type> <name>'
  echo
  echo 'Parameters:'
  echo '  location - Openstack region, e.g. osl, test01'
  echo '  type - The DNS record type, e.g. "A"'
  echo '  name - The name of the record'
  echo
  echo 'Example:'
  echo '  bin/delete_dns_records.sh test01 A test01-db-01.mgmt.test01.uhdc.no'
  echo
  exit 1
}

LOC=$1
TYPE=$2
NAME=$3

if [ $# -ne 3 ]; then
  usage
fi

echo "====> Running playbook: lib/delete_dns_records.yaml"
sudo ansible-playbook -e "myhosts=${LOC}-admin-01 type=${TYPE} name=${NAME}" lib/delete_dns_records.yaml
