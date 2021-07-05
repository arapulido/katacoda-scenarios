#!/bin/bash

# Wait until the datadog agent is available
echo "Waiting for the Datadog agent pod to be running..."
NPODS=$(kubectl get pods -l app=datadog --field-selector=status.phase=Running 2> /dev/null | grep -v NAME | wc -l)
while [ "$NPODS" != "1" ]; do
  sleep 0.3
  NPODS=$(kubectl get pods -l app=datadog --field-selector=status.phase=Running 2> /dev/null | grep -v NAME | wc -l)
done
echo "Datadog Agent ready!"
