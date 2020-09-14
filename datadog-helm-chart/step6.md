The APM (tracing) agent is also disabled by default in the Datadog Helm chart default values. Let's check that, indeed, the APM agent is not currently running:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

You should get the following:

```
...
=========
APM Agent
=========
  Status: Not running or unreachable on localhost:8126.
  Error: Get http://localhost:8126/debug/vars: dial tcp 127.0.0.1:8126: connect: connection refused
...
```

There is a section in the `values.yaml` file to enable APM easily:

```
  ## @param apm - object - required
  ## Enable apm agent and provide custom configs
  #
  apm:
    ## @param enabled - boolean - optional - default: false
    ## Enable this to enable APM and tracing, on port 8126
    ## ref: https://github.com/DataDog/docker-dd-agent#tracing-from-the-host
    #
    enabled: false

    ## @param port - integer - optional - default: 8126
    ## Override the trace Agent port.
    ## Note: Make sure your client is sending to the same UDP port.
    #
    port: 8126

    ## @param useSocketVolume - boolean - optional
    ## Enable APM over Unix Domain Socket
    ## ref: https://docs.datadoghq.com/agent/kubernetes/apm/
    #
    useSocketVolume: false

    ## @param socketPath - string - optional
    ## Path to the trace-agent socket
    #
    socketPath: /var/run/datadog/apm.socket

    ## @param hostSocketPath - string - optional
    ## host path to the trace-agent socket
    #
    hostSocketPath: /var/run/datadog/

```

We are going to enable APM and, instead of using UDP for the communication, we are going to use a Unix Domain Socket, setting `enabled` and `useSocketVolume` to `true`.

We have a `values-apm.yaml` file ready with that section. You can check the difference between the previous applied values file:

`diff -U5 helm-values/values-logs.yaml helm-values/values-apm.yaml`{{execute}}

Let's apply it:

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f helm-values/values-apm.yaml`{{execute}}

Let's run again the agent status command in the Datadog's agent pod running in the worker node:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

Log collection should be enabled now:

```
=========
APM Agent
=========
  Status: Running
  Pid: 1
  Uptime: 40 seconds
  Mem alloc: 12,337,632 bytes
  Hostname: node01
  Receiver: 0.0.0.0:8126
  Endpoints:
    https://trace.agent.datadoghq.com

  Receiver (previous minute)
  ==========================
    No traces received in the previous minute.
    Default priority sampling rate: 100.0%

  Writer (previous minute)
  ========================
    Traces: 0 payloads, 0 traces, 0 events, 0 bytes
    Stats: 0 payloads, 0 stats buckets, 0 bytes
```
