The first thing we are going to do is to deploy the Datadog Operator Helm chart without any additional options. When that happens, the Operator Helm chart will get deployed with the default `values.yaml` that comes with the chart. You can [check these default values in our Helm chart Github repository](https://github.com/DataDog/helm-charts/blob/master/charts/datadog-operator/values.yaml). We will also deploy the `kube-state-metrics` Helm chart, to get additional metrics from Kubernetes.

Let's deploy the charts:

`helm install my-datadog-operator datadog/datadog-operator --version="0.4.0"`{{execute}}
`helm install ksm stable/kube-state-metrics --version="2.8.11"`{{execute}}

Let's check that the Datadog operator pod is running correctly by executing: `kubectl get pods`{{execute}} You should get an output similar to this one:

```
NAME                                  READY   STATUS    RESTARTS   AGE
my-datadog-operator-687d5b45d-8pxtk   1/1     Running   1          3m
```

Once we have the operator up and running, we are ready to deploy the Datadog agent. First, we are going to create two Kubernetes secrets to hold our Datadog API and APP keys:

`kubectl create secret generic datadog-secret --from-literal api-key=$DD_API_KEY`{{execute}}
`kubectl create secret generic datadog-app-key --from-literal app-key=$DD_APP_KEY`{{execute}}

Let's deploy now the Datadog node agent. Open the configuration we are going to apply and review it a bit `dd-operator-configs/datadog-agent-basic.yaml`{{open}}. Can you see the relation between the secrets we just created and that configuration?

Let's apply it:

`kubectl apply -f dd-operator-configs/datadog-agent-basic.yaml`{{execute}}
