#!/bin/bash

CD=$(dirname $(readlink -f $0))
WD="/tmp/hootoo/"

cd $WD
#Unsquashfs
cp mount/firmware/rootfs .
unsquashfs rootfs || exit 1
rm rootfs

cd squashfs-root
echo "Activate telnet"
rm etc/checktelnetflag
cp $CD/../files/opentelnet.sh etc/init.d/opentelnet.sh

echo "Name resolution"
mv etc/resolv.conf etc/resolv.conf.org
cp $CD/../files/resolv.conf etc/resolv.conf

echo "NTP servers replacement"
mv www/script/app/system/time.js www/script/app/system/time.js.org
cp $CD/../files/time.js www/script/app/system/time.js

cd $WD
echo "Re squashing fs..."
$CD/squish.sh $WD/squashfs-root rootfs
rm -fr $WD/squashfs-root
mv $WD/rootfs mount/firmware/rootfs
sync
umount mount
gzip initrdup
cat start_script.sh initrdup.gz > newfirmware
