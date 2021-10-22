Now that we have metrics, APM, logs and the Cluster Agent up and running, we will finish this scenario by enabling Cluster Checks and the Cluster Checks runner.

[Cluster Checks](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/) allow you to monitor this type of workloads, including:

* Out-of-cluster datastores and endpoints (for example, RDS or CloudSQL).
* Load-balanced cluster services (for example, Kubernetes services).

Open the file called `dd-operator-configs/datadog-cluster-checks.yaml`{{open}} and check how we have added a `config` section to the `clusterAgent` section and a new `clusterChecksRunner` section:

```
  clusterAgent:
    image:
      name: "datadog/cluster-agent:1.15.0"
    config:
      clusterChecksEnabled: true
  clusterChecksRunner:
    enabled: true
    image:
      name: "datadog/agent:7.31.0"
```

You can check the differences between the previous configuration and this one by running the following command:

`diff -U3 dd-operator-configs/datadog-agent-agents.yaml dd-operator-configs/datadog-cluster-checks.yaml`{{execute}}

That configuration option will enable Cluster Checks and will force the deployment of 1 replica of the [Cluster Check Runner agent](https://docs.datadoghq.com/agent/cluster_agent/clusterchecksrunner/?tab=operator), an agent that is specifically dedicated to running cluster checks.

Let's apply this new object description:

`kubectl apply -f dd-operator-configs/datadog-cluster-checks.yaml`{{execute}}

You can follow the update from the `DatadogAgent` object status (type `Ctrl+C` to return to the terminal once you can see the agents running and ready):

`kubectl get datadogagent -w`{{execute}}

```
controlplane $ kubectl get datadogagent -w
NAME      ACTIVE   AGENT              CLUSTER-AGENT     CLUSTER-CHECKS-RUNNER   AGE
datadog   True     Updating (2/1/1)   Running (1/1/1)   Progressing (1/0/1)     30m
datadog   True     Running (2/1/2)    Running (1/1/1)   Running (1/1/1)         30m
datadog   True     Running (2/2/2)    Running (1/1/1)   Running (1/1/1)         31m
```

Now, apart from the `DaemonSet` that deploys the node agents, and the `Deployment` for the Cluster Agent, this configuration creates a new `Deployment`:

`kubectl get deploy datadog-cluster-checks-runner`{{execute}}

```
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
datadog-cluster-checks-runner   1/1     1            1           2m33s
```

Any cluster check that we configure in this cluster will be dispatched by the Cluster Agent to the Cluster Check Runner pod.

If you want to learn more about Cluster Checks and the Cluster Checks Runner, you can follow this other [snippet scenario in our lab environment](https://labs.datadoghq.com/snippets/introduction-to-cluster-checks-and-endpoint-checks).
