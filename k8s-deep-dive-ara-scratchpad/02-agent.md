The Datadog agent runs as a `DaemonSet` with a replica on every node in the cluster that matches the selector.

The workshop includes the manifests to install the agent. For more details, see the [official documentation](https://docs.datadoghq.com/agent/kubernetes/daemonset_setup/).
You can check the Daemonset definition opening this file: `assets/02-datadog-agent/agent-daemonset.yaml`{{open}}.

* Install the agent in your cluster: <br/>
`kubectl apply -f assets/02-datadog-agent`{{execute}}

* Verify the `DaemonsetSet` is deployed, and a replica is running on your worker node `node01`.

* Wait for all datadog-agent pods to enter `Running` state.

  * `kubectl get ds`{{execute}} to get a list of all DaemonSets in the current namespace.
  * `kubectl get pods`{{execute}} prints a list of all pods in the current namespace. <br/> <br/>
  * `kubectl get pods -owide`{{execute}} prints a list of all pods with extra information, including the assigned node. <br/> <br/>
  * `kubectl get pods -w`{{execute}} prints and updates a list of all pods as changes occur on the server. (Press <kbd>Ctrl</kbd>+<kbd>C</kbd> to end the watch)
