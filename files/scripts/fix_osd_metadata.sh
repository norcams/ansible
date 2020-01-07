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
sdp=/dev/vg_cache2/lv_dbp

for disknum in a b c d e f g h i j k l m n o; do
  osdnum=$(ceph-volume lvm list /dev/sd$disknum |grep ===== | cut -d' ' -f2 | cut -c 5-)
  db_dev="sd${disknum}"
  realdb_dev=${!db_dev}
  vgdevice=$(ceph-volume lvm list /dev/sd$disknum | grep "block device" | tr -d '[:space:]'| sed -r 's/^blockdevice//')
  lvmuuid=$(lvdisplay $realdb_dev |grep UUID | tr -d '[:space:]'| sed -r 's/^LVUUID//')

# set tags on block device
  lvchange --addtag ceph.db_device=$realdb_dev $vgdevice
  lvchange --addtag ceph.db_uuid=$lvmuuid $vgdevice

# get tags from block device
  gettags=$(lvs -o lv_tags $vgdevice | grep ceph.block_device)
  echo "input tags: $gettags"
  puttags=$(echo $gettags | sed 's/type=block/type=db/g')
  echo "output tags: $puttags"

# put elements into array
  IFS=',' read -r -a metadata <<< "$puttags"
# write metadata to db device
  for element in "${metadata[@]}"
  do
    echo "$element"
    lvchange --addtag $element $realdb_dev
  done
done

