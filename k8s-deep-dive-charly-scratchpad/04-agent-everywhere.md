The agent should run on all nodes in our cluster. To tolerate the master taint as well as any others that may be created, the agent should tolerate all taints. 

We have created a new Helm `values.yaml` file that includes this section:

```
  tolerations:
    - key: node-role.kubernetes.io/master
      effect: NoSchedule
```

You can view this new section opening this file: `assets/04-datadog-agent-everywhere/values.yaml`{{open}}. Navigate to line 975 to check the section.

* Apply the new `values.yaml`: <br/>
`helm upgrade datadogagent --set datadog.apiKey=$DD_API_KEY -f assets/04-datadog-agent-everywhere/values.yaml stable/datadog`{{execute}}

* Verify that the agent is running on the master and worker nodes by executing `kubectl get pods -owide`{{execute}}
