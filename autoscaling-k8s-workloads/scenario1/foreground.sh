#!/bin/bash

NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)


while [ "$NPODS" != "4" ]; do
  echo "Num pods: $NPODS"
  sleep 0.3
  NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)
done

echo "Pods ready!"