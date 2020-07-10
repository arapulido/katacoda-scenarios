Many widgets (including the workload metrics for DaemonSets, Deployments, ReplicaSets, Containers) on the [kubernetes dashboard](https://app.datadoghq.com/screen/integration/86) rely on the `kube-state-metrics` integration.

This data is provided by [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics). Also known as KSM, `kube-state-metrics` is a service that watches the Kubernetes API and generates metrics for the state of objects. You can find the official Datadog documentation [here](https://docs.datadoghq.com/integrations/kubernetes/#setup-kubernetes-state) for the check.

The agent will automatically discover `kube-state-metrics` pods and collect metrics from their OpenMetrics endpoint.

KSM is not deployed by default in most Kubernetes distributions, so the first thing we would need to do is to deploy it:

* Install `kube-state-metrics` on your cluster by executing `kubectl apply -f assets/07-datadog-ksm`{{execute}}
* Validate that `kube-state-metrics` pods are running in the `kube-system` namespace, executing `kubectl get pods -n kube-system`{{execute}}.

<details>
<summary>Explanation</summary>
The `-n` flag to `kubectl` change the namespace of your query.
</details>

A dedicated service account for KSM is granting permissions to access the Kubernetes API. With RBAC enabled, the manifests include a `ClusterRole` and `ClusterRoleBinding` to grant permissons. You can check the permissions granted to KSM describing its `ClusterRole` object: `kubectl describe clusterrole kube-state-metrics`{{execute}}

<details>
<summary>Details</summary>
`kubectl get clusterrole` prints a list of `ClusterRole` objects in the cluster. <br/> <br/>

`kubectl get clusterrolebinding` prints a list of `ClusterRoleBinding` objects in the cluster. <br/> <br/>

`kubectl describe clusterrolebinding` prints details about a `ClusterRoleBinding`, including the subjects it binds to.
</details>

Agent checks are performed by the agent running on the same node as the target. Since it has no tolerations, `kube-state-metrics` will always be running on the worker node, `node01`. Let's verify that the agent is collecting KSM metrics by running the `status` command in datadog-agent pod that also runs in the `node01` node by executing the following commands:

* `NODE01POD=kubectl get pod -l app=datadog-agent --field-selector spec.nodeName=node01 -o custom-columns=:metadata.name`{{execute}}
* `kubectl exec -ti $NODE01POD -- agent status`{{execute}}

<details>
<summary>Explanation</summary>

The command `kubectl get pod -l app=datadog-agent --field-selector spec.nodeName=node01 -o custom-columns=:metadata.name` gets the name of the datadog-agent pod that is running in the `node01` worker node and assign this name to a variable.

We command `kubectl exec -ti $NODE01POD -- agent status` runs the `agent status` command inside the datadog-agent container.
</details>

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

Widgets on the default [dashboard](https://app.datadoghq.com/screen/integration/86) will begin reporting.
