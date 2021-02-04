We have now metrics being sent to Datadog for every NGINX pod in the nginx deployment. But, in some cases, you want to get metrics from non-containerized workloads. [Cluster Checks](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/) allow you to monitor this type of workloads, including:

 * Out-of-cluster datastores and endpoints (for example, RDS or CloudSQL).
 * Load-balanced cluster services (for example, Kubernetes services).

In order to enable Cluster Checks, we will need to deploy a second type of Datadog Agent: the [Datadog Cluster Agent](https://docs.datadoghq.com/agent/cluster_agent/). Deploying this agent has many benefits, as it will act as a proxy between the API server and the node agents, alleviating the load of the API server.

Among other features, the Cluster Agent will schedule the different cluster level checks, making sure that only one worker agent is performing the check, avoiding duplication of data.

Let's enable the Cluster Agent, by modifying the Helm values that we applied in the first step of this scenario.

We will set the following options:

```
clusterAgent.enabled: true
clusterChecks.enabled: true
clusterName: katacoda
```

The option `clusterAgent.enabled: true` will force the deployment of the Cluster Agent. The default values will deploy 1 replica of the Cluster Agent.
The option `clusterChecks.enabled: true` will enable the Cluster Checks feature.
The option `clusterName: katacoda` will give a name (`katacoda`) to our cluster, that will help us organize our cluster level metrics by cluster.

You can check the differences between the previous values file and this new one running the following command: `diff cluster-checks-files/helm/cluster-agent-values.yaml cluster-checks-files/helm/default-values.yaml`{{execute}}

Let's upgrade our Helm release to use this new values file:

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f cluster-checks-files/helm/cluster-agent-values.yaml --version=2.8.1`{{execute}}