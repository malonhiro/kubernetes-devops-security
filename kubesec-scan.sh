scan_score=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].score )

if [[ "${scan_score}" -ge 5 ]];then
    echo "score is $scan_score"
else
    echo "score is $scan_score,which is less than 5"
    exit 1
fi
