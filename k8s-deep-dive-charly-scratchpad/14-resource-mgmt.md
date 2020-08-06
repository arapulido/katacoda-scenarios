In order to get good insight into how to properly monitor Resource Management, start by deploying the following application

`kubectl apply -f assets/workshop-assets/apps/manifests/americano-job.yaml`{{execute}}

After a few seconds, you should see that pod(s) are stuck in a `Pending` state and as a result they are not running.

<details>
<summary>Help</summary>
If you do not see the pod appearing, describe the resource to make sure one has been scheduled:

`kubectl describe cronjobs americano-job`{{execute}}

You should see something like this:

```
Events:
  Type    Reason            Age   From                Message
  ----    ------            ----  ----                -------
  Normal  SuccessfulCreate  56s   cronjob-controller  Created job americano-job-1596039720
```
</details>

When pods are stuck in a pending state because of resource allocation, 2 good indicators are:

- Using `kubectl` to describe the pod and the node to see if there is enough room to be scheduled
- Metrics collected about the pods and the node

* Start by using your terminal to identify how much memory and cpu are available on the worker node.

You only have a few minutes to solve this - Because of the current issue, the number of pods created will grow unbounded...

```
kubectl get pods -lapp=americano | wc -l
6
```

<details>
<summary>Hints</summary>

If you `kubectl describe pod <POD_NAME>` you will see some more details about the state of the pod, the requirements for it to run and what is going wrong.
Then use `kubectl describe node node01` to see how much memory and cpu are available.

Note: If you use the metrics server, you could use commands such as `kubectl top node node01` and `kubectl top pod <POD_NAME>` to have the metrics available with kubectl.
</details>

* Use Datadog to confirm the above finding.

<details>
<summary>Hints</summary>
The [notebook](https://app.datadoghq.com/notebook) is a great way to conduct investigations or create postmortems. Create one to represent:
- The number of pods that cannot be scheduled.
- The memory limits/request per pods.
- The cpu limits/request per pods.
- The cpu and memory usage per pod.

Then compare to the node CPU and memory to see if there is enough headroom for the `americano` app.
</details>

Do not forget about the kubernetes state metrics, refer to [the list of metrics](https://docs.datadoghq.com/agent/kubernetes/data_collected/#kube-state-metrics) collected and identify the ones that could be relevant for this investigation.

<details>
<summary>Hints</summary>
`kubernetes_state.pod.status_phase` is giving you the count of the containers currently reporting per `phase` of the pod lifecycle (pending, running, succeeded, ...).
`kubernetes_state.container.cpu_requested` and `kubernetes_state.container.memory_requested` will also be relevant.
</details>

Given your findings, determine an adequate set of values and update the deployment to be correctly scheduled.
Notice that the proper fix takes more than just adjusting the values because of the type of application that `americano` is. Make sure you end this scenario with no `Pending` pods.

You can edit the file in `assets/workshop-assets/apps/manifests/americano-job.yaml` but make sure you check out the solution before moving to the next step.

<details>
<summary>Fix/Explanation</summary>
These pods failed to run because the pod is requesting an absurdly large amount of
resources: 5000 CPU millicores (5 whole CPUs) and 32GB of memory.<br/><br/> 

A metric query that identifies this issue is to look at pods in error
`kubernetes_state.pod.status_phase` filtered on
`phase:pending`<br/><br/> 

In this case because the pod comes from a cronjob, we see that we are getting
more and more scheduling errors over time as every minute a new pod is created
by the cronjob. This is because of the concurrency policy: The cron job allows concurrently running jobs.
You want to make sure that in our case we use `Replace`. If it is time for a new job run and the previous job run hasn't finished yet, the cron job replaces the currently running job run with a new job run.
More details about this in the [Official Kubernetes doc](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/).

We have to patch the cronjob and then purge the old pods that will never be able to be scheduled. <br/><br/>

A more reasonable request for resources might be: 50 millicores and 50 MB.<br/><br/>

Then to delete all the pending pods you can find a label that matches on all
those pods: here `app=americano`.<br/><br/>

`kubectl delete pod -lapp=americano`{{execute}}

Wait for the newest pod coming from the cronjob to be scheduled
properly.<br/><br/>

We included a sample patch as a solution:<br/><br/>
`kubectl patch cronjob americano-job --patch="$(cat assets/workshop-assets/apps/fixes/americano-fix.yaml)"`{{execute}}
</details>