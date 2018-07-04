#!/bin/bash

# print help
function usage {
  echo
  echo 'Run this script to finish up deploying designate'
  echo 'bin/patch-designate.sh <location>'
  echo
  exit 1
}

LOC=$1

if [ $# -ne 1 ]; then
  usage
fi

ansible-playbook -e "myhosts=${LOC}-identity-01,${LOC-dns-01} identity_node=${LOC-identity-01}" lib/designate_deploy.yaml
