curl -s https://datadoghq.dev/katacodalabtools/r?raw=true|bash

touch /root/status.txt
sleep 1
STATUS=$(cat /root/status.txt)

if [ "$STATUS" != "complete" ]; then
  echo ""> /root/status.txt
  wall -n "Creating ecommerce deployment"

  git clone -b progressive https://github.com/arapulido/katacoda-scenarios-files.git manifest-files

  # Add Helm 3
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  helm repo add datadog https://helm.datadoghq.com
  helm repo add nginx https://helm.nginx.com/stable
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

  echo "Deploying NGINX Ingress controller"
  helm install nginx nginx/nginx-ingress --set controller.service.type=NodePort --set controller.service.httpPort.nodePort=32000 -n kube-system

  echo "Creating the ecommerce application and deploying datadog"
  kubectl create ns database
  kubectl create ns ns1
  kubectl create ns fake-traffic
  kubectl apply -f manifest-files/database -n database
  kubectl apply -f manifest-files/ecommerce-v1 -n ns1 
  kubectl apply -f manifest-files/fake-traffic -n fake-traffic
  
  # NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)

  # while [ "$NPODS" != "4" ]; do
  #   sleep 0.3
  #   NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)
  # done

  echo "complete">>/root/status.txt
fi
