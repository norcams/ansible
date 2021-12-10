#!/bin/bash

# print help
function usage {
  echo
  echo 'Run this script to delete a single DNS record'
  echo
  echo 'USAGE:'
  echo '  bin/delete_dns_record.sh <location> <type> <name>'
  echo
  echo 'Parameters:'
  echo '  location - Openstack region, e.g. osl, test01'
  echo '  type - The DNS record type, e.g. "A"'
  echo '  name - The name of the record'
  echo
  echo 'Examples:'
  echo '  bin/delete_dns_record.sh test01 A test01-db-01.mgmt.test01.uhdc.no'
  echo '  bin/delete_dns_record.sh osl PTR 43.63.37.158.in-addr.arpa'
  echo
  exit 1
}

LOC=$1
TYPE=$2
NAME=$3

if [ $# -ne 3 ]; then
  usage
fi

echo "====> Running playbook: lib/delete_dns_record.yaml"
sudo ansible-playbook -e "myhosts=${LOC}-admin-01 type=${TYPE} record=${NAME}" lib/delete_dns_record.yaml
