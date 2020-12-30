#!/bin/bash
#
# Stop all OSDs on storage host and disable them
#
for osd in `ceph-volume lvm list |grep ===== | cut -d' ' -f2 | cut -c 5-` ; do
  while ! /bin/ceph osd ok-to-stop $osd &>/dev/null ; do
    echo "Not OK to stop OSD $osd now. Waiting..."
    sleep 30
  done
  echo "OK to stop OSD $osd now. Set OSD down..."
  /bin/systemctl stop ceph-osd@$osd.service
  /bin/systemctl disable ceph-osd@$osd.service
  /bin/sleep 5
#  echo "$osd"
done
