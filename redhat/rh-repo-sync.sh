#!/bin/bash

MIRROR_BASE_PATH=/packages
GCP_REGION=us-central1
RH_REPO_NAME=""
USAGE="Usage: $0 -h <RedHat repo name: e.g rhui-rhel-8-for-x86_64-baseos-rhui-rpms > -b <base path, default:/packages>"

while getopts b:h: flag
do
    case "${flag}" in
        b) MIRROR_BASE_PATH=${OPTARG};;
        h) RH_REPO_NAME=${OPTARG};;
        :) echo $USAGE ; exit 1 ;;
        \?) echo $USAGE ; exit 1 ;;
    esac
done

if [ "$RH_REPO_NAME" == "" ]
then
        echo $USAGE
        exit 1
fi

sudo yum install yum-utils  

sudo mkdir -p $MIRROR_BASE_PATH
sudo reposync -p $MIRROR_BASE_PATH --repo=$RH_REPO_NAME