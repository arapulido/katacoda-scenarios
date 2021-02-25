Let's see how we can add environment variables to the `DatadogAgent` definition and we will fix the Kubelet check in the process.

Let's run again the agent status command in the Datadog's agent pod running in the worker node:

`kubectl exec -ti $(kubectl get pods -l agent.datadoghq.com/name=datadog -l agent.datadoghq.com/component=agent -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

We are getting the following error:

```
kubelet (5.0.0)
---------------
Instance ID: kubelet:d884b5186b651429 [ERROR]
Configuration Source: file:/etc/datadog-agent/conf.d/kubelet.d/conf.yaml.default
Total Runs: 9
Metric Samples: Last Run: 0, Total: 0
Events: Last Run: 0, Total: 0
Service Checks: Last Run: 0, Total: 0
Average Execution Time : 1ms
Last Execution Date : 2021-01-20 13:48:46.000000 UTC
Last Successful Execution Date : Never
Error: Unable to detect the kubelet URL automatically: impossible to reach Kubelet with host: 172.17.0.17. Please check if your setup requires kubelet_tls_verify = false. Activate debug logs to see all attempts made
Traceback (most recent call last):
  File "/opt/datadog-agent/embedded/lib/python3.8/site-packages/datadog_checks/base/checks/base.py", line 876, in run
    self.check(instance)
  File "/opt/datadog-agent/embedded/lib/python3.8/site-packages/datadog_checks/kubelet/kubelet.py", line 295, in check
    raise CheckException("Unable to detect the kubelet URL automatically: " + kubelet_conn_info.get('err', ''))
datadog_checks.base.errors.CheckException: Unable to detect the kubelet URL automatically: impossible to reach Kubelet with host: 172.17.0.17. Please check if your setup requires kubelet_tls_verify = false. Activate debug logs to see all attempts made
```

That error happens because we cannot verify the Kubelet certificates correctly. As this is not a production environment, let's tell the Datadog agent to skip the TLS verification by setting the environment variable called `DD_KUBELET_TLS_VERIFY` to `false`.

Open the file called `dd-operator-configs/datadog-agent-kubelet.yaml`{{open}} and check how we have added a `env` section to the `agent` section to add the needed environment variable:

```
    env:
      - name: DD_KUBELET_TLS_VERIFY
        value: "false"
```

You can check the differences between the previous `DatadogAgent` configuration file and this new one running the following command: `diff -U1 dd-operator-configs/datadog-agent-tolerations.yaml dd-operator-configs/datadog-agent-kubelet.yaml`{{execute}}

Let's apply this new object description:

`kubectl apply -f dd-operator-configs/datadog-agent-kubelet.yaml`{{execute}}

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

The Kubelet check should run now successfully:

```
kubelet (5.0.0)
---------------
Instance ID: kubelet:d884b5186b651429 [OK]
Configuration Source: file:/etc/datadog-agent/conf.d/kubelet.d/conf.yaml.default
Total Runs: 9
Metric Samples: Last Run: 243, Total: 2,181
Events: Last Run: 0, Total: 0
Service Checks: Last Run: 4, Total: 36
Average Execution Time : 180ms
Last Execution Date : 2021-01-20 13:55:32.000000 UTC
Last Successful Execution Date : 2021-01-20 13:55:32.000000 UTC
```
