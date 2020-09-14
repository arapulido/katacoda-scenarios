Right now we have deployed Datadog's node agent. A Daemonset that ensures at least 1 replica per node in our cluster.

Another type of Datadog's Kubernetes agent is the [Cluster Agent](https://docs.datadoghq.com/agent/cluster_agent/), that acts a proxy between the API server and the agents, and provides cluster level monitoring data.

The Cluster Agent is disabled by default in the Datadog Helm chart default values. There is a section in the `values.yaml` file to enable the Cluster Agent and to set the number of replicas:

```
...
## @param clusterAgent - object - required
## This is the Datadog Cluster Agent implementation that handles cluster-wide
## metrics more cleanly, separates concerns for better rbac, and implements
## the external metrics API so you can autoscale HPAs based on datadog metrics
## ref: https://docs.datadoghq.com/agent/kubernetes/cluster/
#
clusterAgent:
  ## @param enabled - boolean - required
  ## Set this to true to enable Datadog Cluster Agent
  #
  enabled: false
...
...
...
  ## @param replicas - integer - required
  ## Specify the of cluster agent replicas, if > 1 it allow the cluster agent to
  ## work in HA mode.
  #
  replicas: 1
...
```

We are going to enable the Cluster Agent and leave the replicas to `1`.

We have a `values-cluster-agent.yaml` file ready with that section. You can check the difference between the previous applied values file:

`diff helm-values/values-apm.yaml helm-values/values-cluster-agent.yaml`{{execute}}

Let's apply it:

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f helm-values/values-cluster-agent.yaml`{{execute}}

