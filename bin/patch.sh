#!/bin/bash

#David Tre (david.tre07@gmail.com)
#https://github.com/DavidTre07

# This script will patch downloaded, splitted and mounted firmware image (Doanload and split script)

#Current directory of the script
CD=$(dirname $(readlink -f $0))
#Working directory
WD="/tmp/hootoo/"
#New firmware name
FW="newfirmware"

#Some verifications
type -P unsquashfs >/dev/null
if [ $? -ne 0 ];then
    echo "unsquashfs is missing"
    exit 1
fi

cd $WD
cp mount/firmware/rootfs .
unsquashfs rootfs || exit 1
rm rootfs

cd squashfs-root
echo "Activating telnet"
rm etc/checktelnetflag
cp $CD/../files/opentelnet.sh etc/init.d/opentelnet.sh

echo "Name resolution patching"
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
cat start_script.sh initrdup.gz > $FW

echo "Calculating new CRC..."
CRC=`$CD/checksum_tool.sh $FW`
echo "New CRC: $CRC"
sed -i -e"s/^CRCSUM=.*/CRCSUM=$CRC/" start_script.sh

cat start_script.sh initrdup.gz > $FW
echo "A new firmware has been generated: $WD/$FW"
echo "Cross your fingers and flash it... I hope it will works..."