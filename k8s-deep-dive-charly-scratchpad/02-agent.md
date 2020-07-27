The Datadog agent runs as a `DaemonSet` with a replica on every node in the cluster that matches the selector. To ease its deployment we are going to use Helm.

* Copy your API key from the Datadog agent configuration page and export it as an environment variable: <br/>
`export DD_API_KEY=<your-api-key>`{{copy}}.

* Now run the helm install command: `helm install datadogagent --set datadog.apiKey=$DD_API_KEY -f assets/02-datadog-agent/values.yaml stable/datadog`{{execute}}

For more details, see the [official documentation](https://docs.datadoghq.com/agent/kubernetes/?tab=helm). You can check the `values.yaml` that we are passing by opening this file: `assets/02-datadog-agent/values.yaml`{{open}}.

* Verify the `DaemonsetSet` is deployed, and a replica is running on your worker node `node01`.

* Notice that the datadog agent pod is restarting: Investigate

<details>
<summary>Hint</summary>
The health port is 5555 but in values we specified 1234, the file
assets/02-datadog-agent/healthport_fix.yaml contains the right configuration.
Use helm upgrade to just apply this path:
 * `helm upgrade datadogagent -f assets/02-datadog-agent/values.yaml stable/datadog --reuse-values`

</details>

Once fixed wait for the datadog-agent pod to enter `Running` state.

  * `kubectl get ds`{{execute}} to get a list of all DaemonSets in the current namespace.
  * `kubectl get pods`{{execute}} prints a list of all pods in the current namespace. <br/> <br/>
  * `kubectl get pods -owide`{{execute}} prints a list of all pods with extra information, including the assigned node. <br/> <br/>
  * `kubectl get pods -w`{{execute}} prints and updates a list of all pods as changes occur on the server. (Press <kbd>Ctrl</kbd>+<kbd>C</kbd> to end the watch)

