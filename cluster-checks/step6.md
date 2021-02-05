We have now our HTTP Cluster Check running in the Node Agent that is deployed to `node01`. This is fine, as our cluster is small and we are not running that many checks anyway.

But in a production environment, with many nodes and many applications running on your cluster, it is very likely that your Node Agents are already busy running checks for the pods that are scheduled on those nodes.

To avoid adding the load of the cluster checks, there is an option to deploy a special type of worker agent only focused on running your cluster checks. We are going to deploy 1 replica of this type of worker agent using the Helm chart values file.

We will set the following options:

```
clusterChecksRunner.enabled: true
clusterChecks.replicas: 1
```

The option `clusterChecksRunner.enabled: true` will create a new deployment for Cluster Checks Runners.
The option `clusterChecksRunner.replicas: 1` will ensure that we are deploying only 1 pod.

You can check the differences between the previous values file and this new one running the following command: `diff -U6 cluster-checks-files/helm/cluster-checks-runner.yaml cluster-checks-files/helm/cluster-agent-values.yaml`{{execute}}

Let's upgrade our Helm release to use this new values file:

`helm delete datadog && helm install datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f cluster-checks-files/helm/cluster-checks-runner.yaml --version=2.8.1`{{execute}}