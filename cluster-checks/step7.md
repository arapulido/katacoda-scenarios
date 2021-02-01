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

`diff -U4 helm-values/values-apm.yaml helm-values/values-cluster-agent.yaml`{{execute}}

Let's apply it:

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f helm-values/values-cluster-agent.yaml`{{execute}}

As with the node agents, several Kubernetes objects were created. Let's check the secrets first: `kubectl get secrets`{{execute}} You should get an output similar to this one:

```
NAME                                     TYPE                                  DATA   AGE
...
datadog-cluster-agent                    Opaque                                1      3m23s
datadog-cluster-agent-token-n6j2n        kubernetes.io/service-account-token   3      3m23s
...
```

The most important one is the one called `datadog-cluster-agent`. This is a secret that was automatically created and that contains a generated token that will be used to secure the communication between your node agents and your cluster agent.

The other `token` secret is the one used by the service account to communicate with the API server.

Let's check the workloads that have been deployed:

`kubectl get deployments`{{execute}}

```
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
datadog-cluster-agent        1/1     1            1           24m
...

```

Now, let's check that both of our Node Agents are connected to the Cluster Agent successfully:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}
`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=controlplane) -- agent status`{{execute}}

In both cases you should get an output similar to this one:

```
...
=====================
Datadog Cluster Agent
=====================

  - Datadog Cluster Agent endpoint detected: https://10.98.143.176:5005
  Successfully connected to the Datadog Cluster Agent.
  - Running: 1.7.0+commit.4568d4d
```

Finally, let's run the agent `status` command in the Cluster Agent pod:

`kubectl exec -ti $(kubectl get pods -l app=datadog-cluster-agent -o custom-columns=:.metadata.name) -- agent status`{{execute}}

The Kubernetes API check should run successfully:

```
    kubernetes_apiserver
    --------------------
      Instance ID: kubernetes_apiserver [OK]
      Configuration Source: file:/etc/datadog-agent/conf.d/kubernetes_apiserver.d/conf.yaml.default
      Total Runs: 111
      Metric Samples: Last Run: 0, Total: 0
      Events: Last Run: 0, Total: 0
      Service Checks: Last Run: 3, Total: 333
      Average Execution Time : 15ms
      Last Execution Date : 2020-09-14 14:19:40.000000 UTC
      Last Successful Execution Date : 2020-09-14 14:19:40.000000 UTC
```
