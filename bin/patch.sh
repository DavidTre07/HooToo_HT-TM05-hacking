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
$CD/squish.sh squashfs-root rootfs
rm -fr squashfs-root
mv rootfs mount/firmware/rootfs
sync
umount mount
gzip initrdup
cat start_script.sh initrdup.gz > newfirmware

CRC=`$CD/checksum_tool.sh newfirmware`
echo "New CRC: $CRC"
sed -i -e"s/^CRCSUM=.*/CRCSUM=$CRC/" start_script.sh
cat start_script.sh initrdup.gz > newfirmware
