Logs collection is disabled by default in the Datadog Helm chart default values. Let's check that, indeed, the logs agent is not currently running:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

You should get the following:

```
...
==========
Logs Agent
==========


  Logs Agent is not running
...
```

There is a section in the `values.yaml` file to enable log collection easily:

```
  ## @param logs - object - required
  ## Enable logs agent and provide custom configs
  #
  logs:
    ## @param enabled - boolean - optional - default: false
    ## Enables this to activate Datadog Agent log collection.
    ## ref: https://docs.datadoghq.com/agent/basic_agent_usage/kubernetes/#log-collection-setup
    #
    enabled: false

    ## @param containerCollectAll - boolean - optional - default: false
    ## Enable this to allow log collection for all containers.
    ## ref: https://docs.datadoghq.com/agent/basic_agent_usage/kubernetes/#log-collection-setup
    #
    containerCollectAll: false

    ## @param containerUseFiles - boolean - optional - default: true
    ## Collect logs from files in /var/log/pods instead of using container runtime API.
    ## It's usually the most efficient way of collecting logs.
    ## ref: https://docs.datadoghq.com/agent/basic_agent_usage/kubernetes/#log-collection-setup
    #
    containerCollectUsingFiles: true
```

We will set both `enabled` and `containerCollectAll` to true, to enable log collection and to collect logs from all containers in our cluster.

We have a `values-logs.yaml` file ready with that section. You can check the difference between the previous applied values file:

`diff -U5 helm-values/values-kubelet.yaml helm-values/values-logs.yaml`{{execute}}

Let's apply it:

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f helm-values/values-logs.yaml`{{execute}}

Let's run again the agent status command in the Datadog's agent pod running in the worker node:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

Log collection should be enabled now:

```
==========
Logs Agent
==========

    Sending compressed logs in HTTPS to agent-http-intake.logs.datadoghq.com on port 443
    BytesSent: 0
    EncodedBytesSent: 28
    LogsProcessed: 0
    LogsSent: 0
```
