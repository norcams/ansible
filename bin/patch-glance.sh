#!/bin/bash

# print help
function usage {
  echo ""
  echo "Run this script to update the size error message in dashboard."
  echo "And to hide create volume in the workflow for sources in dashboard."
  echo "bin/patch-dashboard.sh <location>-dashboard-01"
  echo ""
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "myhosts=${host} patchfile=${HOME}/ansible/files/patches/horizon-tables-size.diff dest=/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/instances/tables.py" lib/patch.yaml
sudo ansible-playbook -e "myhosts=${host} patchfile=${HOME}/ansible/files/patches/horizon-hide-create-volume-bootsource.diff dest=/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/static/dashboard/project/workflow/launch-instance/launch-instance-model.service.js" lib/patch.yaml
sudo ansible-playbook -e "myhosts=${host} name=httpd" lib/systemd_restart.yaml

/ansible/files/patches/glance-fix-CVE-2022-47951.diff
/usr/lib/python3.6/site-packages/glance
