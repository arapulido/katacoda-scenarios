The Datadog agent runs as a `DaemonSet` with a replica on every node in the cluster that matches the selector. To ease its deployment we are going to use Helm.


* The Datadog agent uses an API key to report data to your account, yours was injected as an environment variable ($DD_API_KEY) when you logged into the lab. Verify that the key is correctly injected: <br/>

`echo $DD_API_KEY`{{execute}}

* Now run the helm install command: `helm install datadogagent --set datadog.apiKey=$DD_API_KEY -f assets/workshop-assets/02-datadog-agent/values.yaml stable/datadog`{{execute}}

For more details, see the [official documentation](https://docs.datadoghq.com/agent/kubernetes/?tab=helm). You can check the `values.yaml` that we are passing by opening this file: `assets/workshop-assets/02-datadog-agent/values.yaml`{{open}}.

* Verify the `DaemonsetSet` is deployed, and a replica is running on your worker node `node01`.

* Notice that the datadog agent pod has 3 containers, but only 2 are Ready, and the pod is restarting:

```
datadogagent-wns85                               2/3     Running   1          2m21s
datadogagent-cctcn                               2/3     CrashLoopBackOff   4          2m37s
```

Investigate why the 3 containers are not all in a Ready state, use the "Hint" if you need help and make sure you run the command in "Solution".

<details>
<summary>Hint</summary>
Describe the pod running the Datadog agent:

`kubectl describe pod -lapp=datadogagent`{{execute}}
The events should be self explanatory, but you will see that the probes are failing, so look into their configurations and compare them to the health port the agent is configured to use.
</details>

<details>
<summary>Solution</summary>
The health port the agent uses is 5555 but in the probes are specified on 1234 and 5678, the file
assets/02-datadog-agent/value_fix.yaml contains the right configuration.

Use helm upgrade to just apply this path:
 * `helm upgrade datadogagent --set datadog.apiKey=$DD_API_KEY -f assets/workshop-assets/02-datadog-agent/values_fix.yaml stable/datadog`{{execute}}
</details>

Once fixed wait for all of the containers in the datadog-agent pod to enter a `Running` state.

Tips and tricks:

  * `kubectl get ds`{{execute}} to get a list of all DaemonSets in the current namespace.
  * `kubectl get pods`{{execute}} prints a list of all pods in the current namespace. <br/> <br/>
  * `kubectl get pods -owide`{{execute}} prints a list of all pods with extra information, including the assigned node. <br/> <br/>
  * `kubectl get pods -w`{{execute}} prints and updates a list of all pods as changes occur on the server. (Press <kbd>Ctrl</kbd>+<kbd>C</kbd> to end the watch)

