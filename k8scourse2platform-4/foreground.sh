
while [ ! `ls -l /root/k8s-yaml-files/*.yaml 2>/dev/null | wc -l ` -eq 6 ]; do
  sleep 0.3
done
while [ ! 'k get nodes 2>/dev/null | wc -l ' -eq 2 ]; do
  sleep 0.3
done

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl completion bash >/etc/bash_completion.d/kubectl
complete -F __start_kubectl k
kubectl create secret generic datadog-secret --from-literal=api-key=$DD_API_KEY
# kubectl krew install match-name
cd k8s-yaml-files
clear
prepenvironment
