touch status.txt
echo ""> /root/status.txt
if [ ! -f "/root/provisioned" ]; then
fi
wall -n "Creating ecommerce deployment"

kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/db.yaml
kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/advertisements.yaml
kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/discounts.yaml
kubectl apply -f https://raw.githubusercontent.com/arapulido/ecommerce-app-kubernetes-manifests/master/frontend.yaml

echo "complete">>/root/status.txt