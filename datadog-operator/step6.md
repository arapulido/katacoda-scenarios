The default configuration file that we have applied deploys default versions for the Node Agent and the Cluster Agent, based on the Operator version.

In a production environment, though, we would like to control what versions of the Node and Cluster Agents we are deploying in our cluster.

Open the file called `dd-operator-configs/datadog-agent-versions.yaml`{{open}} and check how we have added an `agent` and `clusterAgent` sections to specify the images we want to deploy:

```
[...]
  agent:
    image:
      name: "datadog/agent:7.31.0"
  clusterAgent:
    image:
      name: "datadog/cluster-agent:1.15.0"
```

You can check the differences between the previous `DatadogAgent` configuration file and this new one running the following command: `diff -U3 dd-operator-configs/datadog-agent-basic.yaml dd-operator-configs/datadog-agent-versions.yaml`{{execute}}

Let's apply this new object description:

`kubectl apply -f dd-operator-configs/datadog-agent-versions.yaml`{{execute}}

You can follow the update from the `DatadogAgent` object status (type `Ctrl+C` to return to the terminal once you can see the agents running and ready):

`kubectl get datadogagent -w`{{execute}}

```
NAME      ACTIVE   AGENT                 CLUSTER-AGENT      CLUSTER-CHECKS-RUNNER   AGE
datadog   True     Progressing (1/0/1)   Updating (2/1/1)                           7m17s
datadog   True     Progressing (1/0/1)   Updating (2/2/1)                           7m25s
datadog   True     Progressing (1/0/1)   Running (1/1/1)                            7m37s
datadog   True     Running (1/1/1)       Running (1/1/1)                            8m2s
```
