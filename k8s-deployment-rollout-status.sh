#!/bin/bash

sleep 60s

if [[ $(kubectl -n default rollout status deploy ${deploymentName} --timeout 5s) != "successfully rolled out" ]]; then
    echo "deployment ${deploymentName} rollout has failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1
else
    echo "deployment ${deploymentName} rollout is success"
fi