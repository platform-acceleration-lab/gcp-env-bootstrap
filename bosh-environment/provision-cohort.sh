#!/usr/bin/env bash

if [ $# -ne 4 ]; then
    echo "Usage: ./deprovsion-cohort.sh <cohort prefix> <cohort id> <course> <gcp folder id>"
    exit 1
fi

cohort_prefix=$1
cohort_id=$2
course=$3
gcp_folder_id=$4
gcs_path="${course}/${cohort_id}"

projects=$(ls -d envs/${cohort_prefix}-*)

echo "The following projects will be provisioned:"

for project in ${projects[*]}; do
    echo "- ${project}"
done

read -p "Are you sure (y/n) ? " -r

if [[ ! $REPLY =~ ^[Yy]  ]]; then
  exit 2
fi

tmux new-session -d -s "deprovision-${cohort_id}"

for project in ${projects[*]}; do
  tmux new-window -t "provision-${cohort_id}" bash -lic "${project}/provision.sh ${gcp_folder_id} ${gcs_path} 2>&1 | tee ${project}/provision-log.txt";
done