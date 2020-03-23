touch status.txt
echo ""> /root/status.txt
wall -n "Creating ecommerce deployment"

git clone https://github.com/arapulido/autoscaling-workshop-files.git k8s-manifests
cd k8s-manifests

kubectl apply -f metrics-server/
kubectl apply -f ecommerce-app/

NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)

while [ "$NPODS" != "5" ]; do
  sleep 0.3
  NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)
done

echo "complete">>/root/status.txt
