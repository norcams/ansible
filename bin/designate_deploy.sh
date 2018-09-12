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

echo "====> Running playbook: lib/designate_pool_update.yaml"
ansible-playbook -e "myhosts=${LOC}-dns-01" lib/designate_pool_update.yaml

#echo "====> Running playbook: lib/designate_deploy.yaml"
#ansible-playbook -e "myhosts=${LOC}-identity,${LOC}-dns" lib/designate_deploy.yaml
