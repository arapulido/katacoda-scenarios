Let's see how we can change some configuration values from the Helm chart and we will fix the Kubelet check in the process.

Let's run again the agent status command in the Datadog's agent pod running in the worker node:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

We are getting the following error:

```
    kubelet (4.1.1)
    ---------------
      Instance ID: kubelet:d884b5186b651429 [ERROR]
      Configuration Source: file:/etc/datadog-agent/conf.d/kubelet.d/conf.yaml.default
      Total Runs: 37
      Metric Samples: Last Run: 0, Total: 0
      Events: Last Run: 0, Total: 0
      Service Checks: Last Run: 0, Total: 0
      Average Execution Time : 0s
      Last Execution Date : 2020-09-11 13:24:02.000000 UTC
      Last Successful Execution Date : Never
      Error: Unable to detect the kubelet URL automatically.
      Traceback (most recent call last):
        File "/opt/datadog-agent/embedded/lib/python3.8/site-packages/datadog_checks/base/checks/base.py", line 841, in run
          self.check(instance)
        File "/opt/datadog-agent/embedded/lib/python3.8/site-packages/datadog_checks/kubelet/kubelet.py", line 297, in check
          raise CheckException("Unable to detect the kubelet URL automatically.")
      datadog_checks.base.errors.CheckException: Unable to detect the kubelet URL automatically.
```

That error happens because we cannot verify the Kubelet certificates correctly. As this is not a production environment, let's tell the Datadog agent to skip the TLS verification by setting the environment variable called `DD_KUBELET_TLS_VERIFY` to `false`.

Setting environment variables in the `values.yaml` file is easy: there is a section to do just that:

```
  ## @param env - list of object - optional
  ## The dd-agent supports many environment variables
  ## ref: https://docs.datadoghq.com/agent/docker/?tab=standard#environment-variables
  #
  env: []
```

Let's modify that section to set that environment variable:

```
  ## @param env - list of object - optional
  ## The dd-agent supports many environment variables
  ## ref: https://docs.datadoghq.com/agent/docker/?tab=standard#environment-variables
  #
  env:
    - name: DD_KUBELET_TLS_VERIFY
      value: false
```

We have a `values-kubelet.yaml` file ready with that section. You can check the difference between the previous applied values file:

`diff helm-values/values-tolerations.yaml helm-values/values-kubelet.yaml`{{execute}}

Let's apply it:

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f helm-values/values-kubelet.yaml`{{execute}}

Let's run again the agent status command in the Datadog's agent pod running in the worker node:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

The Kubelet check should run now successfully.
