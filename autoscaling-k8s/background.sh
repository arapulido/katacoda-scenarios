touch /root/status.txt
sleep 1
STATUS=$(cat /root/status.txt)

if [ "$STATUS" != "complete" ]; then
  echo ""> /root/status.txt
  wall -n "Creating ecommerce deployment"

  git clone https://github.com/arapulido/autoscaling-workshop-files.git k8s-manifests

  NNODES=$(kubectl get nodes | grep Ready | wc -l)

  while [ "$NNODES" != "2" ]; do
    sleep 0.3
    NNODES=$(kubectl get nodes | grep Ready | wc -l)
  done

  # Wait until the API server is available
  NPODS=$(kubectl get pods -n kube-system -l component=kube-apiserver --field-selector=status.phase=Running | grep -v NAME | wc -l)
  while [ "$NPODS" != "1" ]; do
    sleep 0.3
    NPODS=$(kubectl get pods -n kube-system -l component=kube-apiserver --field-selector=status.phase=Running | grep -v NAME | wc -l)
  done

  echo "Applying metrics server, kube-state-metrics and commerce app"
  kubectl create ns fake-traffic
  kubectl apply -f k8s-manifests/metrics-server/
  kubectl apply -f k8s-manifests/kube-state-metrics/
  kubectl apply -f k8s-manifests/ecommerce-app/

  NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)

  while [ "$NPODS" != "4" ]; do
    sleep 0.3
    NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)
  done

  echo "complete">>/root/status.txt
fi
