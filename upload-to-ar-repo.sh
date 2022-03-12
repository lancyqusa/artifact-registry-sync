#!/bin/bash

MIRROR_BASE_PATH=/packages/mirror/security.ubuntu.com/ubuntu/pool/main/
GCP_REGION=us-central1
USAGE="Usage: $0 -t <Repo type: yum|apt> -a <Artifact Registry repo name> -r <GCP region> -m <local path to mirrored packages, default:/packages/mirror/security.ubuntu.com/ubuntu/pool/main/"

while getopts t:a:r:m: flag
do
    case "${flag}" in
        a) GCP_AR_REPO_NAME=${OPTARG};;
        r) GCP_REGION=${OPTARG};;
        m) MIRROR_BASE_PATH=${OPTARG};;
        t) GC_AR_REPO_TYPE=${OPTARG};;
        :) echo $USAGE ; exit 1 ;;
        \?) echo $USAGE ; exit 1 ;;
    esac
done

if [ -z $GCP_AR_REPO_NAME ] || [ -z $GC_AR_REPO_TYPE ]
then
        echo $USAGE
        exit 1
fi

BASE_OS_LOCAL_MIRROR=${MIRROR_BASE_PATH}
BASE_OS_ARTIFACT_REG_REPO=$GCP_AR_REPO_NAME
[ "$GC_AR_REPO_TYPE" == "yum" ] && MIRROR_WILDCARD='*.rpm'
[ "$GC_AR_REPO_TYPE" == "apt" ] && MIRROR_WILDCARD='*.deb'
FIND_CMD="find $BASE_OS_LOCAL_MIRROR -name $MIRROR_WILDCARD"

LOGFILE=$0.log
>$LOGFILE
function trap_ctrlc ()
{
        # perform cleanup here
        echo "Ctrl-C caught...performing clean up" | tee -a $LOGFILE

        echo "Doing cleanup" | tee -a $LOGFILE
        echo "interrupted script at `date`" | tee -a $LOGFILE

        # exit shell script with error code 2
        # if omitted, shell script will continue execution
        exit 2
}

trap "trap_ctrlc" 2

echo "`date` : Started script " | tee -a $LOGFILE
echo "`date` : BASE_OS_LOCAL_MIRROR=$BASE_OS_LOCAL_MIRROR" | tee -a $LOGFILE
echo "`date` : BASE_OS_ARTIFACT_REG_REPO=$BASE_OS_ARTIFACT_REG_REPO" | tee -a $LOGFILE
echo "`date` : MIRROR_WILDCARD=$MIRROR_WILDCARD" | tee -a $LOGFILE
echo "`date` : FIND_CMD=$FIND_CMD" | tee -a $LOGFILE
read
for i in `$FIND_CMD `
do
        echo "`date` : processing $i" | tee -a $LOGFILE
        gcloud beta artifacts $GC_AR_REPO_TYPE upload $BASE_OS_ARTIFACT_REG_REPO --location=$GCP_REGION --source=$i
        if [ $? ]
done
echo "`date` : Script done " | tee -a $LOGFILE