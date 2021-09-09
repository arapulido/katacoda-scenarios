As we have seen, the [Datadog Cluster Agent can work as External Metrics Server](https://docs.datadoghq.com/agent/cluster_agent/external_metrics/).

To use the Cluster Agent as External Metrics Server we will need to modify our Datadog Helm installation and set the `clusterAgent.metricsProvider.enabled` option to `true`. You can check the differences between our previous Helm chart values files and the one we are going to use now:

`diff -U3 k8s-manifests/datadog/datadog-helm-values.yaml k8s-manifests/datadog/datadog-helm-values-external-metrics.yaml`{{execute}}

Also, in order to be able to use the Cluster Agent as External Metrics Server, we need to retrieve the APP key (different from the API key) for our Datadog organization. To make things easier we have already injected your Datadog APP key in an environment variable. Check that it has a value by executing `echo $DD_APP_KEY`{{execute}}

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY --set datadog.appKey=$DD_APP_KEY datadog/datadog -f k8s-manifests/datadog/datadog-helm-values-external-metrics.yaml --version=2.16.6`{{execute}}

Wait until the Datadog agent is running by executing this command: `wait-cluster-agent.sh`{{execute}}

Once the pod is running, let's check that the metrics server has been started correctly. Execute the following command: `kubectl exec -ti deploy/datadog-cluster-agent -- agent status`{{execute}} If the Metrics Server has been eanbled correctly, you should get the following output:

```
Custom Metrics Server
=====================
  ConfigMap name: default/datadog-custom-metrics
  External Metrics
  ----------------
    Total: 0
    Valid: 0
```
