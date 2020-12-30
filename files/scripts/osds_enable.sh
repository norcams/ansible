#!/bin/bash
#
# Enable all OSDs without starting them
#
for osd in `ceph-volume lvm list |grep ===== | cut -d' ' -f2 | cut -c 5-` ; do
  echo "Enabling OSD $osd."
  /bin/systemctl enable ceph-osd@$osd.service
done
