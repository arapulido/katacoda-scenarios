The Kubernetes integration comes with multiple out of the box dashboards to help understand the data being collected. 
![Screenshot of Kubernetes Dashboard](./assets/k8sdashboard.png)


At the highest level, you can use the [Kubernetes Overview dashoard](https://app.datadoghq.com/screen/integration/86/kubernetes---overview)

Note that this dasboard gives a good overview, but you can dig deeper into the different parts of Kubernetes.

At the node level for instance, you can see the high overview of how your applications are reporting with the [Kubernetes Node Overview dashboard](https://app.datadoghq.com/screen/integration/30340/kubernetes-nodes-overview)

If you want to go at a lower level you can take a look at the [Kubernetes Pod Overview dashboard](https://app.datadoghq.com/screen/integration/30322).

You can also monitor the different components of the Control Plane:

* [Kubernetes Scheduler](https://app.datadoghq.com/screen/integration/30270/kubernetes-scheduler)
* [Kubernetes Controller Manager](https://app.datadoghq.com/screen/integration/30271/kubernetes-controller-manager)
* [ETCD](https://app.datadoghq.com/screen/integration/30289/etcd-overview)

Most of these dashboards display data from the OpenMetrics endpoints of the applications (apiserver, kubelet, etcd ...) but the agent is also using [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics). Also known as KSM, `kube-state-metrics` is a service that watches the Kubernetes API and generates metrics for the state of objects. You can find the official Datadog documentation [here](https://docs.datadoghq.com/integrations/kubernetes/#setup-kubernetes-state) for the check.

The agent will automatically discover `kube-state-metrics` pods and collect metrics from their OpenMetrics endpoint.

Let's verify that the agent is collecting KSM metrics by running the `status` command in datadog-agent pod that also runs in the `node01` node by executing the following commands:

* `NODE01POD=kubectl get pod -l app=datadog-agent --field-selector spec.nodeName=node01 -o custom-columns=:metadata.name`{{execute}}
* `kubectl exec -ti $NODE01POD -- agent status`{{execute}}

Look for:
```
=========
Collector
=========
  Running Checks
  ==============
    kubernetes_state (1.0.0)
    ------------------------------
      Instance ID: kubernetes_state:822c2bebb015713 [OK]
      Total Runs: 10
      Metric Samples: Last Run: 1,251, Total: 12,510
      Events: Last Run: 0, Total: 0
      Service Checks: Last Run: 1, Total: 10
      Average Execution Time : 1.102s
```