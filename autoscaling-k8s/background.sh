curl -s https://datadoghq.dev/katacodalabtools/r?raw=true|bash

touch /root/status.txt
sleep 1
STATUS=$(cat /root/status.txt)

if [ "$STATUS" != "complete" ]; then
  echo ""> /root/status.txt
  wall -n "Setting up the environment"

  # Get the manifest files for the scenario
  git clone -b autoscaling https://github.com/arapulido/katacoda-scenarios-files.git k8s-manifests

  # Add Helm 3
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  helm repo add datadog https://helm.datadoghq.com
  helm repo update

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

  wall -n "Deploying metrics server, kube-state-metrics and commerce app"
  sleep 1
  kubectl create ns fake-traffic
  sleep 1
  kubectl apply -f k8s-manifests/metrics-server/
  sleep 1
  kubectl apply -f k8s-manifests/ecommerce-app/
  sleep 1

  NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)

  wall -n "Waiting for the Ecommerce application to be ready"
  while [ "$NPODS" != "4" ]; do
    sleep 0.3
    NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)
  done

  echo "complete">>/root/status.txt
fi
