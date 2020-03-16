touch status.txt
echo ""> /root/status.txt
wall -n "Creating ecommerce deployment"

kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/db.yaml
kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/advertisements.yaml
kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/discounts.yaml
kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/frontend.yaml

NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)

while [ "$NPODS" != "4" ]; do
  sleep 0.3
  NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)
done

echo "complete">>/root/status.txt
