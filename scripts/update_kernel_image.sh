#!/bin/bash

set -e
cd "$(dirname "$(readlink -f "$0")")"

if [ -z "$1" ]
  then
    echo "Must provide the SD device path! i.e. /dev/sdc"
    exit -1
fi

DEV_NAME=$1

ROOT_DIR=$PWD/..
BUILD_DIR=$ROOT_DIR/build
FWM_DIR=$BUILD_DIR/source/output/out_header/

sectorEnd=`fdisk -l | grep "$DEV_NAME:" | awk -F ' ' '{print $7}'`
sectorSize=`fdisk -l | grep -A 2 "$DEV_NAME:" | grep "Units" | awk -F ' ' '{print $6}'`

if [ $sectorSize -ne 512 ];then
    echo "Failed: sector size is not 512!"
    return 1;
fi

# 536870912 bytes is 512M
sectorRsv=$[536870912/sectorSize+1]
sectorEnd=$[sectorEnd-sectorRsv]

#component main/backup offset
COMPONENTS_MAIN_OFFSET=$[sectorEnd+1]
COMPONENTS_BACKUP_OFFSET=$[COMPONENTS_MAIN_OFFSET+73728]

IMAGE_OFFSET=8192
IMAGE_SIZE=65536

OF_DIR=$COMPONENTS_MAIN_OFFSET
dd if=${FWM_DIR}Image of=${DEV_NAME} count=$IMAGE_SIZE seek=$[OF_DIR+IMAGE_OFFSET] bs=$sectorSize
