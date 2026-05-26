# sleep for 10 seconds
sleep 10

project_key="IfscUT"
threshold=0

#Code flow
CURL_URL=$SONAR_HOST'/api/measures/component_tree?metricKeys=coverage&component='$project_key
curl --location --request GET $CURL_URL -u $SONAR_TOKEN:"" > sonar.json
apk update \
&& apk add jq \
&& rm -rf /var/cache/apk/*
jq -r '.baseComponent.measures[0].value' sonar.json
code_coverage=$( jq -r '.baseComponent.measures[0].value' sonar.json | cut -d "." -f 1)
echo $code_coverage
echo "SONAR Threshold is $threshold"
cat sonar.json
if [ -z "$code_coverage" ] || [ $code_coverage = "null" ]; then echo "Value not found"; exit 1; fi
if [ $code_coverage -lt $threshold ]; then echo "failed - threshold unit code coverage check"; exit 1; else echo "success"; exit 0; fi
