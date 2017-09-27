#!/bin/bash
for osd in `ceph-disk list | grep osd | cut -d' ' -f1,8 | sed 's/[^0-9]*//g'` ; do
  /bin/systemctl stop ceph-osd@$osd.service
  /bin/sleep 2
  /bin/ceph osd purge $osd --yes-i-really-mean-it
done
