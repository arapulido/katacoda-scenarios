curl -sk https://datadoghq.dev/katacodalabtools/r?raw=true|bash

touch /root/status.txt
sleep 1
STATUS=$(cat /root/status.txt)

if [ "$STATUS" != "complete" ]; then
  echo ""> /root/status.txt
  wall -n "Setting up the Kubernetes cluster"

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

  # Get the manifest files for the scenario
  git clone -b progressive https://github.com/arapulido/katacoda-scenarios-files.git manifest-files

  # Add Helm 3
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  helm repo add datadog https://helm.datadoghq.com
  helm repo update
  echo "helm installed" >>/root/status.txt

  # Add Istio
  wall -n "Deploying Istio"
  kubectl create ns istio-system
  kubectl apply -f manifest-files/istio/istio-config.yaml
  kubectl apply -f manifest-files/istio/istio-config.yaml

  # Wait for Istio
  NPODS=$(kubectl get pods -n istio-system 2> /dev/null | grep "1/1" | wc -l)
  while [ "$NPODS" != "3" ]; do
    sleep 0.3
    NPODS=$(kubectl get pods -n istio-system 2> /dev/null | grep "1/1" | wc -l)
  done

  wall -n "Deploying the ecommerce application"
  kubectl create ns database
  kubectl create ns ns3
  kubectl create ns fake-traffic
  kubectl apply -f manifest-files/database -n database
  kubectl apply -f manifest-files/fake-traffic -n fake-traffic
  
  echo "complete">>/root/status.txt
fi
