#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to update the size error message in dashboard."
  echo "bin/patch-dashboard.sh <location>-dashboard-01"
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "hosts=${host} patchfile=${HOME}/ansible/files/patches/horizon-tables-size.diff dest=/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/instances/tables.py" lib/patch.yaml
sudo ansible-playbook -e "hosts=${host} name=httpd" lib/systemd_restart.yaml
