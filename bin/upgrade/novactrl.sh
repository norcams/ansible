#!/bin/bash

function usage {
  echo ""
  echo "This will upgrade novactrl in a location, including deps"
  echo "./${0} <location>"
  echo ""
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

loc=$1

sudo ansible-playbook -e "hosts=${loc}-identity-01" lib/puppetrun.yaml
sudo ansible "${loc}-proxy-01" --become -m shell -a '. /root/openrc && for id in `openstack endpoint list --service novav3 -f json | jq -r ".[] | .ID"`; do openstack endpoint delete $id; done'
sudo ansible-playbook -e "hosts=${loc}-db-02" lib/puppetrun.yaml
sudo ansible-playbook -e "hosts=${loc}-db-02" lib/puppetrun.yaml
sudo ansible-playbook -e "hosts=${loc}-novactrl-01" lib/upgrade/nova.yaml
