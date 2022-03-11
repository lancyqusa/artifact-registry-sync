#!/bin/bash

MIRROR_BASE_PATH=/packages
GCP_REGION=us-central1
USAGE="Usage: $0 -c <Ubuntu Code: focal|impish> -r <GCP region> -b <base path, default:/packages>"

while getopts c:r:b: flag
do
    case "${flag}" in
        c) UBUNTU_CODE_NAME=${OPTARG};;
        r) GCP_REGION=${OPTARG};;
        b) MIRROR_BASE_PATH=${OPTARG};;
        :) echo $USAGE ; exit 1 ;;
        \?) echo $USAGE ; exit 1 ;;
    esac
done

if [ "$UBUNTU_CODE_NAME" == "" ]
then
        echo $USAGE
        exit 1
fi

sudo apt install apt-mirror

read -r -d '' MIRROR_LIST_TEMPLATE << EOM
set nthreads     20
set _tilde 0

set base_path    ${MIRROR_BASE_PATH}
set mirror_path  ${MIRROR_BASE_PATH}/mirror
set skel_path    ${MIRROR_BASE_PATH}/skel
set var_path     ${MIRROR_BASE_PATH}/var

deb http://${GCP_REGION}.gce.archive.ubuntu.com/ubuntu/ ${UBUNTU_CODE_NAME}-updates main restricted
deb http://security.ubuntu.com/ubuntu ${UBUNTU_CODE_NAME}-security main restricted

clean http://${GCP_REGION}.gce.archive.ubuntu.com/ubuntu
EOM

MIRROR_LIST_FILENAME=${GCP_REGION}-${UBUNTU_CODE_NAME}-mirror.list

echo "$MIRROR_LIST_TEMPLATE" > $MIRROR_LIST_FILENAME
sudo mkdir -p $MIRROR_BASE_PATH
sudo apt-mirror $MIRROR_LIST_FILENAME