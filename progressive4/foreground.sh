#!/bin/bash

while [ ! -f "/usr/local/bin/prepenvironment" ]; do
  sleep 0.3
done
sleep 0.3

clear

statuscheck helm
helm install datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f manifest-files/datadog/datadog-helm-values.yaml --version=2.16.6

echo "Waiting for the Datadog agent pod to be running..."
NPODS=$(kubectl get pods -l app=datadog 2> /dev/null | grep "3/3" | wc -l)
while [ "$NPODS" != "1" ]; do
  sleep 0.3
  NPODS=$(kubectl get pods -l app=datadog 2> /dev/null | grep "3/3" | wc -l)
done
echo "Datadog Agent ready!"

prepenvironment