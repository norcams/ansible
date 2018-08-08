#/bin/bash

if [ ! -f "ansible.cfg" ]; then
  echo "Run this from ansible root where the ansible git repo is checked out"
  exit 1
fi

function usage {
  echo ""
  echo "This will patch the console server to include a ctrl-alt-delete-button"
  echo "./${0} <location>"
  echo ""
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

loc=$1

sudo ansible-playbook -e "myhosts=${loc}-console-01 patchfile=${HOME}/ansible/files/patches/spice.css-ctrl-alt-delete-button.diff dest=/usr/share/spice-html5/spice.css" lib/patch.yaml
sudo ansible-playbook -e "myhosts=${loc}-console-01 patchfile=${HOME}/ansible/files/patches/spice_auto.html-ctrl-alt-delete-button.diff dest=/usr/share/spice-html5/spice_auto.html" lib/patch.yaml
