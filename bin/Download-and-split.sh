#!/bin/bash

WD=`pwd`
WD=/tmp/hootoo
MOUNTDIR=${WD}/mount

# List of filenames that are important
#
# ARCH_FILENAME is the name of the compressed archive we download from hootoo
# (it used to be a .zip, but now it's a .rar, no now it's back zip !!!)
# UPDATE_FILENAME is the name of the update file we get from the compressed archive
ARCH_FILENAME="HooToo%20TM05-Support%20exFAT&HFS%20-%202.000.068.zip"
UPDATE_FILENAME="fw-7620-WiFiDGRJ-HooToo-HT-TM05-2.000.068"

UPDATE_URL="http://www.hootoo.com/media/downloads/${ARCH_FILENAME}"

UID=`id -u`
if [ ${UID} != 0 ];then
  MOUNT="sudo mount"
else
  MOUNT="mount"
fi

echo "-- Working Dir: $WD"
[ ! -d ${WD} ] && mkdir -p ${WD}
cd ${WD}

if [ ! -f ${WD}/${ARCH_FILENAME} ]; then
  # Need to get and unzip the ZIP file
  wget -O ./${ARCH_FILENAME} ${UPDATE_URL}
  [ $? -ne 0 ] && exit 1
fi

#unrar e ./${ARCH_FILENAME}
unzip ./${ARCH_FILENAME}
if [ $? -ne 0 ]; then
  echo "Unzip / unrar problem... Exiting."
  exit 1
fi

# resulting UPDATE file is a stubfile, so we need to split it
# this gets where the stub ends and the initrdup begins
SPLITLINE=`awk '/^END_OF_STUB/ { print NR + 1; exit 0; }' ${UPDATE_FILENAME}`

# Use the resulting line number to make initrdup.gz and gunzip it
tail -n +${SPLITLINE} ${UPDATE_FILENAME} > initrdup.gz
gunzip initrdup.gz

# Do the same thing for the script at the beginning
head -n $(( ${SPLITLINE} - 1 )) ${UPDATE_FILENAME} > start_script.sh

# mount it somewhere we can work on it
[ ! -d ${MOUNTDIR} ] && mkdir ${MOUNTDIR}
$MOUNT -o loop -t ext2 initrdup ${MOUNTDIR}
echo "-- Mounted at ${MOUNTDIR}"
