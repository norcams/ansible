#/bin/bash

set -o errexit

if [ ! -f "ansible.cfg" ]; then
  echo "Run this from ansible root where the ansible git repo is checked out"
  exit 1
fi

function usage {
  echo ""
  echo "This will setup admin after reinstall."
  echo ""
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

himlar_path='/opt/himlar'
himlarcli_path='/opt/himlarcli'
loc=$1

sudo ansible -u iaas -a "/bin/bash /root/puppet_bootstrap.sh" -m shell ${loc}-admin
sudo ansible-playbook -e "hosts=${loc}-admin" lib/push_secrets.yaml
sudo ansible -u iaas -a "${himlar_path}/provision/puppetrun.sh" -m shell ${loc}-admin
sudo ansible -u iaas -a "${himlar_path}/provision/foreman-settings.sh" -m shell ${loc}-admin
sudo ansible -u iaas -a "source ${himlarcli_path}/bin/activate && ${himlarcli_path}/foreman_setup.py -c ${himlarcli_path}/config.ini.${loc}" -m shell ${loc}-login
sudo ansible-playbook -e "hosts=${loc}-admin" lib/git_access.yaml

