touch /root/status.txt
sleep 1
STATUS=$(cat /root/status.txt)

if [ "$STATUS" != "complete" ]; then
  echo ""> /root/status.txt

  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  helm repo add stable https://kubernetes-charts.storage.googleapis.com

  git clone https://github.com/CharlyF/k8s-workshop.git assets

  echo "Waiting for kubernetes to start" >>/root/status.txt

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

  # Deleting permissive rbac policy
  until curl -ksf https://localhost:6443/healthz ;
  do
	  sleep 5
  done
  kubectl delete clusterrolebinding permissive-binding

  # add audit logs to the apiserver
  mkdir -p /etc/kubernetes/audit-policies
  cp assets/workshop-assets/00-env-prep/policy.yaml /etc/kubernetes/audit-policies/policy.yaml

  # update apiserver config
  grep "audit-policy-file" /etc/kubernetes/manifests/kube-apiserver.yaml || \
	sed -i '/tls-private-key-file/a \ \ \ \ - --audit-policy-file=/etc/kubernetes/audit-policies/policy.yaml' /etc/kubernetes/manifests/kube-apiserver.yaml

  grep "audit-log-path" /etc/kubernetes/manifests/kube-apiserver.yaml || \
	sed -i '/audit-policy-file/a \ \ \ \ - --audit-log-path=/var/log/kubernetes/apiserver/audit.log' /etc/kubernetes/manifests/kube-apiserver.yaml

  grep "path: /etc/kubernetes/audit-policies" /etc/kubernetes/manifests/kube-apiserver.yaml || \
	sed -i '/volumes:/a \ \ - {hostPath: {path: /etc/kubernetes/audit-policies, type: DirectoryOrCreate}, name: k8s-audit-policies}' /etc/kubernetes/manifests/kube-apiserver.yaml

  grep "mountPath: /etc/kubernetes/audit-policies" /etc/kubernetes/manifests/kube-apiserver.yaml || \
	sed -i '/volumeMounts:/a \ \ \ \ - {mountPath: /etc/kubernetes/audit-policies, name: k8s-audit-policies, readOnly: true}' /etc/kubernetes/manifests/kube-apiserver.yaml

  grep "path: /var/log/kubernetes" /etc/kubernetes/manifests/kube-apiserver.yaml || \
	sed -i '/volumes:/a \ \ - {hostPath: {path: /var/log/kubernetes, type: DirectoryOrCreate}, name: k8s-logs}' /etc/kubernetes/manifests/kube-apiserver.yaml

  grep "mountPath: /var/log/kubernetes" /etc/kubernetes/manifests/kube-apiserver.yaml || \
	sed -i '/volumeMounts:/a \ \ \ \ - {mountPath: /var/log/kubernetes, name: k8s-logs}' /etc/kubernetes/manifests/kube-apiserver.yaml

  # Wait until the API server has restarted with the new conf and is available
  NPODS=$(kubectl get pods -n kube-system -l component=kube-apiserver --field-selector=status.phase=Running | grep -v NAME | wc -l)
  while [ "$NPODS" != "1" ]; do
    sleep 0.3
    NPODS=$(kubectl get pods -n kube-system -l component=kube-apiserver --field-selector=status.phase=Running | grep -v NAME | wc -l)
  done

  # Patching etcd's annotations for the check to run without errors
  mv assets/workshop-assets/00-env-prep/etcd.yaml /etc/kubernetes/manifests/etcd.yaml
  NETCD=$(kubectl get pods -n kube-system -l component=etcd --field-selector=status.phase=Running| grep -v NAME | wc -l)
  while [ "$NETCD" != "1" ]; do
    sleep 0.3
    NETCD=$(kubectl get pods -n kube-system -l component=etcd --field-selector=status.phase=Running| grep -v NAME | wc -l)
  done

  wall -n "-- Applying commerce app --"
  kubectl apply -f assets/ecommerce-app/db.yaml
  kubectl apply -f assets/ecommerce-app/advertisements.yaml
  kubectl apply -f assets/ecommerce-app/discounts.yaml
  kubectl apply -f assets/ecommerce-app/frontend.yaml
  #kubectl apply -f assets/ecommerce-app/gor_traffic.yaml

  NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)

  while [ "$NPODS" != "4" ]; do
    sleep 0.3
    NPODS=$(kubectl get pods --field-selector=status.phase=Running | grep -v NAME | wc -l)
  done
  wall -n "-- Commerce app ready --"

  echo "complete">>/root/status.txt
fi
