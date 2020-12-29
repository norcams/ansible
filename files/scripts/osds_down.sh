#!/bin/bash
#
# Set all OSDs for a storage host to "down"
#
for osd in `ceph-volume lvm list |grep ===== | cut -d' ' -f2 | cut -c 5-` ; do
  while ! /bin/ceph osd ok-to-stop $osd &>/dev/null ; do
    echo "Not OK to stop OSD $osd now. Waiting..."
    sleep 30
  done
  echo "OK to stop OSD $osd now. Set OSD down..."
  /bin/ceph osd down $osd
  /bin/sleep 5
#  echo "$osd"
done
