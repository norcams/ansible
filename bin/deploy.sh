#/bin/bash

if [ ! -f "ansible.cfg" ]; then
  echo "Run this from ansible root where the ansible git repo is checked out"
  exit 1
fi

function usage {
  echo ""
  echo "This will deploy himlar puppet code in location."
  echo "./${0} <location>"
  echo ""
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

loc=$1

sudo ansible-playbook -e "myhosts=${loc}-admin" lib/deploy_himlar.yaml
