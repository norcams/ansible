#!/bin/bash
#
# Set all OSDs for a storage host to "out"
#
for osd in `ceph-volume lvm list |grep ===== | cut -d' ' -f2 | cut -c 5-` ; do
  while ! /bin/ceph osd ok-to-stop $osd &>/dev/null ; do
    echo "Not OK to set OSD $osd now. Waiting..."
    sleep 30
  done
  echo "OK to stop OSD $osd now. Stopping..."
  /bin/ceph osd out $osd
  /bin/sleep 5
#  echo "$osd"
done
