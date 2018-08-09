#!/bin/bash

function usage {
  echo ""
  echo "This will upgrade calico on network nodes and compute hosts"
  echo "in a location, but will not delete old etcd data from cluster"
  echo "./${0} <location> --<opt>"
  echo "Example: ./${0} test01"
  echo ""
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

loc=$1

if [ -z $2 ]; then
  opt=""
else
  opt="$2"
fi

sudo ansible-playbook $opt -e "myhosts=${loc}-compute" lib/upgrade/calico31-compute.yaml
sudo ansible-playbook $opt -e "myhosts=${loc}-network" lib/upgrade/calico31-network.yaml
sudo ansible-playbook $opt -e "myhosts=${loc}-compute" lib/upgrade/calico31-compute-2.yaml
