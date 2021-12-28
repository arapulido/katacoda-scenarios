#!/bin/bash

while [ ! -f "/usr/local/bin/prepenvironment" ]; do
  sleep 0.3
done
sleep 0.3

clear

statuscheck helm
helm install datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f manifest-files/datadog/datadog-helm-values.yaml --version=2.16.6

prepenvironment