#!/bin/bash
sda=/dev/vg_cache1/lv_dba
sdb=/dev/vg_cache1/lv_dbb
sdc=/dev/vg_cache1/lv_dbc
sdd=/dev/vg_cache1/lv_dbd
sde=/dev/vg_cache1/lv_dbe
sdf=/dev/vg_cache2/lv_dbf
sdg=/dev/vg_cache2/lv_dbg
sdh=/dev/vg_cache2/lv_dbh
sdi=/dev/vg_cache2/lv_dbi
sdj=/dev/vg_cache2/lv_dbj
sdk=/dev/vg_cache2/lv_dbk
sdl=/dev/vg_cache2/lv_dbl
sdm=/dev/vg_cache2/lv_dbm
sdn=/dev/vg_cache2/lv_dbn
sdo=/dev/vg_cache2/lv_dbo

for disknum in a b c d e f g h i j k l m n o; do
  osdnum=$(ceph-volume lvm list /dev/sd$disknum |grep ===== | cut -d' ' -f2 | cut -c 5-)
  echo $osdnum
  db_dev="sd${disknum}"
  realdb_dev=${!db_dev}
  echo realdb $realdb_dev
  /bin/systemctl stop ceph-osd@$osdnum.service
  /bin/sleep 2
  CEPH_ARGS="--bluestore-block-db-size 85899345920" ceph-bluestore-tool bluefs-bdev-new-db --path /var/lib/ceph/osd/ceph-$osdnum --dev-target $realdb_dev
  rm -rf /var/lib/ceph/osd/ceph-$osdnum/block.db
  ln -s $realdb_dev /var/lib/ceph/osd/ceph-$osdnum/block.db
  chown ceph:ceph $(realpath $realdb_dev)
  chown -R ceph:ceph $realdb_dev
  chown -R ceph:ceph /var/lib/ceph/osd/ceph-$osdnum/block.db
  /bin/sleep 4
  /bin/systemctl start ceph-osd@$osdnum.service
  /bin/sleep 20
done
# Wait for all OSDs to active before proceeding to next node
while ! /bin/ceph status | grep "485 up"; do
  echo "true"
  /bin/sleep 2
done
