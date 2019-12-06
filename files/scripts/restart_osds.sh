#!/bin/bash
for osd in `ceph-volume lvm list |grep ===== | cut -d' ' -f2 | cut -c 5-` ; do
  /bin/systemctl restart ceph-osd@$osd.service
  /bin/sleep 20
done
