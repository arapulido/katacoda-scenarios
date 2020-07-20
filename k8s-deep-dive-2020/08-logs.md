Our current Datadog agent configuration doesn't have logs collection enabled. We will enable log collection by passing two environment variables to the Agent: `DD_LOGS_ENABLED=true` and `DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true`. You can read more on our [official documentation](https://docs.datadoghq.com/agent/kubernetes/daemonset_setup/?tab=k8sfile#log-collection).

We are going to patch our DaemonSet to add the required environment varibles. You can check the patch opening this file: `assets/08-datadog-logs/enable-logs.patch.yaml`{{open}}

Patch the Daemonset executing the following command `kubectl patch daemonset datadog-agent --patch "$(cat assets/08-datadog-logs/enable-logs.patch.yaml)"`{{execute}}

* Check if your change has been rolled out:<br/>
`kubectl get pods -lapp=datadog-agent`{{execute}}

**Even with the new manifest uploaded, pods are not updated. The default rollout strategy for the `DaemonSet` is `OnDelete` [which means according to the documentation](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/) a Pod must be deleted to be replaced. To automatically roll out changes, use the `RollingUpdate` strategy.**
