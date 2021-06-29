The first thing we are going to do is to deploy the Datadog Helm chart without any additional options. When that happens, the Helm chart will get deployed with the default `values.yaml` that comes with the chart. You can [check these default values in our Helm chart Github repository](https://github.com/DataDog/helm-charts/blob/master/charts/datadog/values.yaml).

Let's deploy the chart passing our API key:

`helm install datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f helm-values/values.yaml`{{execute}}

Let's see what wew got from the default configuration.

First, let's check the secrets that were created by executing: `kubectl get secrets`{{execute}} You should get an output similar to this one:

```
NAME                                     TYPE                                  DATA   AGE
datadog                                  Opaque                                1      107m
datadog-kube-state-metrics-token-5kdfj   kubernetes.io/service-account-token   3      107m
datadog-token-d82rx                      kubernetes.io/service-account-token   3      107m
default-token-6bjgs                      kubernetes.io/service-account-token   3      3h28m
sh.helm.release.v1.datadog.v1            helm.sh/release.v1                    1      107m
```

The most important one is the one called `datadog`. This is a secret that was automatically created and that contains your API key. You can check that it actually contains your API key getting the value and base64 decoding it: `kubectl get secret datadog --template='{{index .data "api-key"}}' | base64 -d`{{execute}}.

The other two `token` secrets are the ones used by the service accounts to communicate with the API server.

Let's check the workloads that have been deployed:

`kubectl get deployments`{{execute}}

```
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
datadog-kube-state-metrics   1/1     1            1           15h
```

The Datadog Helm chart, by default, aside from the Datadog agent, deploys [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) by default. Kube State Metrics is a service that listens to the Kubernetes API and generates metrics about the state of the objects. Datadog uses some of these metrics to populate its Kubernetes default dashboard.

`kubectl get daemonset`{{execute}}

```
NAME      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
datadog   1         1         1       1            1           kubernetes.io/os=linux   22h
```

This is the Daemonset that deploys the Datadog node agent. To be able to gather information from the Kubelet and system metrics from each of the nodes, the Datadog node agent deploys at least 1 node agent pod per node. Let's check how many pods do we have after deploying the Daemonset and which nodes are they deployed to:

`kubectl get pods -l app=datadog -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName`{{execute}}

You should get an output similar to this one:

```
NAME            NODE
datadog-mhv58   node01
```

The Datadog node agent was deployed to the worker node, but not the control plane node. Why? There is a taint in the control plane node that prevents pods without the corresponding toleration being scheduled in that node:

`kubectl get nodes controlplane -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints`{{execute}}

If we want to monitor the control plane nodes, we will need to add a toleration for the control-plane nodes. We will explain how to do this in the next step.

Let's check the status of the Datadog agent:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:metadata.name) -- agent status`{{execute}}

Check the different checks that are running by default. You can see that the Kubelet check is failing. We will fix the configuration in a later step to fix this.
