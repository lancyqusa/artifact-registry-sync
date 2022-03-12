#!/bin/bash

GCP_REGION=us-central1
USAGE="Usage: $0 -t <Repo type: yum|apt> -a <Artifact Registry repo name> -r <GCP region> -d <description (optional)>"

while getopts t:a:rd flag
do
    case "${flag}" in
        a) GCP_AR_REPO_NAME=${OPTARG};;
        r) GCP_REGION=${OPTARG};;
        d) GC_AR_DESC=${OPTARG};;
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

if [ "$GC_AR_DESC" == "" ]
then
    GC_AR_DESC="Repo created on `date` for type $GC_AR_REPO_TYPE in region $GCP_REGION"
fi
echo "--description: $GC_AR_DESC" > /tmp/desc.yaml
GCLOUD_CMD="gcloud beta artifacts repositories create $GCP_AR_REPO_NAME --repository-format=$GC_AR_REPO_TYPE --location=$GCP_REGION --flags-file=/tmp/desc.yaml"
$GCLOUD_CMD