Logs collection, APM and the process monitoring are disabled by default in the `DatadogAgent` object unless enabled explicitely.

For example, if you run the agent status command:

`kubectl exec -ti $(kubectl get pods -l agent.datadoghq.com/name=datadog -l agent.datadoghq.com/component=agent -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

You should get the following:

```
[...]
==========
Logs Agent
==========


  Logs Agent is not running
[...]
```

The Datadog Operator makes it very easy to enable logs, APM and process monitoring. Open the file called `dd-operator-configs/datadog-agent-agents.yaml`{{open}} and check how we have added an `apm`, a `process` and a `log` sections to the `agent` section to enable those features.

```
apm:
  enabled: true
process:
  enabled: true
log:
  enabled: true
  logsConfigContainerCollectAll: true
```

You can check the differences between the previous `DatadogAgent` configuration file and this new one running the following command: `diff -U1 dd-operator-configs/datadog-agent-kubelet.yaml dd-operator-configs/datadog-agent-agents.yaml`{{execute}}

Let's apply this new object description:

`kubectl apply -f dd-operator-configs/datadog-agent-agents.yaml`{{execute}}

You can follow the update from the `DatadogAgent` object status (type `Ctrl+C` to return to the terminal once you can see the agents running and ready):

`kubectl get datadogagent -w`{{execute}}

```
controlplane $ kubectl get datadogagent -w
NAME      ACTIVE   AGENT              CLUSTER-AGENT   CLUSTER-CHECKS-RUNNER   AGE
datadog   True     Updating (2/1/1)                                           8m9s
datadog   True     Updating (2/1/1)                                           8m13s
datadog   True     Running (2/1/2)                                            8m43s
datadog   True     Running (2/2/2)                                            8m52s
```

Once the updated pods are up and running, run again the agent status command in the Datadog's agent pod running in the worker node:

`kubectl exec -ti $(kubectl get pods -l agent.datadoghq.com/name=datadog -l agent.datadoghq.com/component=agent -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

Log collection should be enabled now (and APM and process monitoring):

```
==========
Logs Agent
==========

    Sending compressed logs in HTTPS to agent-http-intake.logs.datadoghq.com on port 443
    BytesSent: 3.289499e+06
    EncodedBytesSent: 100075
    LogsProcessed: 1976
    LogsSent: 1972
```
