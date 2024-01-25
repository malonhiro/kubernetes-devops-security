echo $ImageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $ImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $ImageName

exit_code=$?

echo "Exist code: $exit_code"

if [[ "${exit_code}" == 1 ]];then
    echo "image scan failed"
    exit 1
else
    echo "image scan pass"
fi