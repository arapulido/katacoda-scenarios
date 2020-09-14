As we said, our cluster has two nodes, one worker and one control plane node, but the agent only deployed to the worker node. We are going to add a toleration to our deployment definition to match the control plane node.

This is fairly easy to do using the Datadog Helm chart, as there is a specific section in the `values.yaml` file to add tolerations:

```
## @param tolerations - array - optional
## Allow the DaemonSet to schedule on tainted nodes (requires Kubernetes >= 1.6)
#
tolerations: []
```

We are going to edit that section to look like the following:

```
## @param tolerations - array - optional
## Allow the DaemonSet to schedule on tainted nodes (requires Kubernetes >= 1.6)
#
tolerations:
  - key: node-role.kubernetes.io/master
    effect: NoSchedule
```

We have a `values-tolerations.yaml` file ready with that section. Let's apply it:

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY datadog/datadog -f helm-values/values-tolerations.yaml`{{execute}}

Let's check now the number of pods we have for the Datadog agent and the nodes they are deployed to:

`kubectl get pods -l app=datadog -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName`{{execute}}

```
NAME            NODE
datadog-qglsd   controlplane
datadog-vz26z   node01
```

We now have correctly one Datadog agent deployed to the control plane node.
