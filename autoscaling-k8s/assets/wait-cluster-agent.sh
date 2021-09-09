#!/bin/bash

# Wait until the datadog agent is available
echo "Waiting for the Datadog cluster agent to be running..."
NPODS=$(kubectl get pods -l app.kubernetes.io/component=cluster-agent 2> /dev/null | grep -v NAME | wc -l)
while [ "$NPODS" != "1" ]; do
  sleep 0.3
  NPODS=$(kubectl get pods -l app.kubernetes.io/component=cluster-agent 2> /dev/null | grep -v NAME | wc -l)
done

NPODS=$(kubectl get pods -l app.kubernetes.io/component=cluster-agent --field-selector=status.phase=Running 2> /dev/null | grep -v NAME | wc -l)
while [ "$NPODS" != "1" ]; do
  sleep 0.3
  NPODS=$(kubectl get pods -l app.kubernetes.io/component=cluster-agent --field-selector=status.phase=Running 2> /dev/null | grep -v NAME | wc -l)
done
echo "Datadog Cluster Agent ready!"
