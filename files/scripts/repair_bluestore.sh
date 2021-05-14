#!/bin/bash
#for osd in `ceph-disk list | grep osd | cut -d' ' -f1,8 | sed 's/[^0-9]*//g'` ; do
for osd in `ceph-volume lvm list |grep ===== | cut -d' ' -f2 | cut -c 5-` ; do
  /bin/systemctl stop ceph-osd@$osd.service
  /bin/sleep 2
  /bin/ceph-bluestore-tool repair --path /var/lib/ceph/osd/ceph-$osd
  /bin/chown ceph:ceph /var/lib/ceph/osd/ceph-$osd/block.db
  /bin/chown -h ceph:ceph /var/lib/ceph/osd/ceph-$osd/block.db
  /bin/sleep 5
  /bin/systemctl start ceph-osd@$osd.service
done
