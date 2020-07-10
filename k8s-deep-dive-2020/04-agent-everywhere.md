The agent should run on all nodes in our cluster. To tolerate the master taint as well as any others that may be created, the agent should tolerate all taints. 

The workshop includes a patch to add the required toleration, you can review it opening this file: `assets/04-datadog-agent-everywhere/tolerate-all.patch.yaml`{{open}}.

* Apply the patch: <br/>
`kubectl patch daemonset datadog-agent --patch "$(cat assets/04-datadog-agent-everywhere/tolerate-all.patch.yaml)"`{{execute}}

* Verify that the agent is running on the master and worker nodes by executing `kubectl get pods -owide`{{execute}}
