#!/bin/bash

# print help
function usage {
  echo
  echo 'Run this script to finish up deploying designate'
  echo 'USAGE:'
  echo '  bin/designate_deploy.sh <location>'
  echo
  exit 1
}

LOC=$1

if [ $# -ne 1 ]; then
  usage
fi

echo "====> Running playbook: lib/designate_pool_update.yaml"
sudo ansible-playbook -e "myhosts=${LOC}-dns-01" lib/designate_pool_update.yaml

### We're not running the sink service
#echo "====> Running playbook: lib/designate_sink_config.yaml"
#ansible-playbook -e "myhosts=${LOC}-identity,${LOC}-dns" lib/designate_sink_config.yaml
