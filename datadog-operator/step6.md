Now that we have the node agent up and running with APM, Logs and Process monitoring enabled, let's change our `DatadogAgent` configuration to deploy the Cluster Agent.

The [Datadog Cluster Agent](https://docs.datadoghq.com/agent/cluster_agent/) provides a streamlined, centralized approach to collecting cluster level monitoring data. By acting as a proxy between the API server and node-based Agents, the Cluster Agent helps to alleviate server load. It also relays cluster level metadata to node-based Agents, allowing them to enrich the metadata of locally collected metrics.

The Cluster Agent is also required to enable the [Kubernetes resources view](https://docs.datadoghq.com/infrastructure/livecontainers/?tab=helm#kubernetes-resources-view) in the Live Containers page, that we will do in this step as well.

Open the file called `dd-operator-configs/datadog-cluster-agent.yaml`{{open}} and check the sections `clusterAgent` and `features`:

```
  clusterAgent:
    image:
      name: "datadog/cluster-agent:latest"
  features:
    orchestratorExplorer:
      enabled: true
```

The section `clusterAgent` section forces the deployment of the Cluster Agent, and `features.orchestratorExplorer` enables the Kubernetes resources view.

Let's apply this new object description:

`kubectl apply -f dd-operator-configs/datadog-cluster-agent.yaml`{{execute}}

You can follow the update from the `DatadogAgent` object status (type `Ctrl+C` to return to the terminal once you can see the agents running and ready):

`kubectl get datadogagent -w`{{execute}}

```
controlplane $ kubectl get datadogagent -w
NAME      ACTIVE   AGENT              CLUSTER-AGENT     CLUSTER-CHECKS-RUNNER   AGE
datadog   True     Updating (2/1/1)   Running (1/1/1)                           3m25s
datadog   True     Updating (2/1/1)   Running (1/1/1)                           4m3s
datadog   True     Running (2/2/2)    Running (1/1/1)                           4m29s
```

Now, apart from the `DaemonSet` that deploys the node agents, this configuration creates a new `Deployment`:

`kubectl get deploy datadog-cluster-agent`{{execute}}

```
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
datadog-cluster-agent   1/1     1            1           5m42s
```

In this case, we are only deploying 1 replica of the cluster agent. 

As we discussed, the Node Agents need to communicate with the Cluster Agent to get metrics from the API server. We can check that this connection is happening correctly running `status` command against the Node Agents:

`kubectl exec -ti $(kubectl get pods -l agent.datadoghq.com/name=datadog -l agent.datadoghq.com/component=agent -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

You should get an output similar to this one:

```
=====================
Datadog Cluster Agent
=====================

  - Datadog Cluster Agent endpoint detected: https://10.97.142.200:5005
  Successfully connected to the Datadog Cluster Agent.
  - Running: 1.10.0+commit.a285fcc
```

We have also enabled the Orchestrator Explorer, to enable the Kubernetes resources view. Let's check that it is running correctly by running the `status` command, this time against the Cluster Agent:

`kubectl exec -ti deploy/datadog-cluser-agent -- agent status`

You should get an output similar to this one:

```
[...]
=====================
Orchestrator Explorer
=====================
  ClusterID: 99a3a7e1-af52-4f8a-8d88-c0aae85a22c9
  ClusterName: katacoda
  ContainerScrubbing: Enabled
[...]
```

Open now the [Live Containers view in Datadog](https://app.datadoghq.com/orchestration/overview/pod?cols=name%2Cstatus%2Cready%2Crestarts%2Cage%2Clabels&paused=false&sort=&tags=kube_cluster_name%3Akatacoda) to watch your Kubernetes objects directly from Datadog:

