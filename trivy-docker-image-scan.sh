dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severiry HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severiry CRITICLAL --light $dockerImageName

exit_code=$?

echo "Exist code: $exit_code"

if [[ "${exit_code}" == 1]];then
    echo "image scan failed"
    exit 1
else
    echo "image scan pass"
fi;