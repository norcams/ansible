#!/bin/bash

# print help
function usage {
  echo
  echo 'Run this script to patch the designate nova notification_handler'
  echo 'bin/patch-dashboard.sh <location>-dashboard-01'
  echo
  exit 1
}

host=$1

if [ $# -ne 1 ]; then
  usage
fi

sudo ansible-playbook -e "hosts=${host} patchfile=${HOME}/ansible/files/patches/designate_notification_handler.diff basedir=/usr/lib/python2.7/site-packages/designate" lib/patch.yaml
sudo ansible-playbook -e "hosts=${host} name=httpd" lib/systemd_restart.yaml
