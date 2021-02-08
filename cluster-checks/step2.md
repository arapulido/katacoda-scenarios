The first thing we are going to do is to deploy the Datadog node agent, using the Helm Chart. We will be using the `cluster-checks-files/helm/default-values.yaml`{{open}} values file. Open that file if you want to check what values we are using to deploy the Datadog agent. If you want to learn more about Datadog's Helm chart, you can follow this other [Labs scenario](https://labs.datadoghq.com/snippets/an-introduction-to-the-different-options-for-datadog-helm-chart).

Let's deploy the chart passing our API key:

`helm install datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f cluster-checks-files/helm/default-values.yaml --version=2.8.1`{{execute}}

Let's check the workloads that have been deployed:

`kubectl get deployments`{{execute}}

```
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
datadog-kube-state-metrics   1/1     1            1           15h
```

The Datadog Helm chart, by default, aside from the Datadog agent, deploys [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics). Kube State Metrics is a service that listens to the Kubernetes API and generates metrics about the state of the objects. Datadog uses some of these metrics to populate its Kubernetes default dashboard.

`kubectl get daemonset`{{execute}}

```
NAME      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
datadog   1         1         1       1            1           kubernetes.io/os=linux   22h
```
This is the Daemonset that deploys the Datadog node agent.

Let's wait until all the pods are running before continuing (type `Ctrl+C` to return to the terminal once all the pods are running):

`kubectl get pods -w`{{execute}}

Now that the pods are up and running, let's check the status of the Datadog agent:

`kubectl exec -ti ds/datadog -- agent status`{{execute}}

Check the different checks that are running by default:

```
[...]
=========
Collector
=========

  Running Checks
  ==============
    
    cpu
    ---
      Instance ID: cpu [OK]
      Configuration Source: file:/etc/datadog-agent/conf.d/cpu.d/conf.yaml.default
      Total Runs: 6
[...]
```
