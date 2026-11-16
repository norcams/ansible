#/bin/bash

if [ ! -f "ansible.cfg" ]; then
    echo "Run this from ansible root where the ansible git repo is checked out"
    exit 1
fi

function usage {
    echo ""
    echo "This will deploy imagebuilder python lib in location."
    echo "./${0} <location>"
    echo ""
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

loc=$1

sudo ansible-playbook -e "myhosts=${loc}-builder-01" lib/deploy_imagebuilder.yaml
