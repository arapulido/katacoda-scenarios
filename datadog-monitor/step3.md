Now that we have the Datadog node and cluster agents running and collecting metrics, we want to use those metrics to generate alerts. We will start with our system metrics.

We have 2 hosts/nodes in our cluster, and we want to keep an eye to their disk usage to make sure that they don't fill up, as that would have an impact on the scheduling of pods that mount a host or an empty volume. We want to get alerted if the disk usage is over 50%.

Let's navigate to the [Notebook](https://app.datadoghq.com/notebook) section in Datadog to help us build the query we want to alert on:

![Screenshot of New Notebook](./assets/new_notebook.png)

Let's modify the metric to `system.disk.in_use` and let's group by `host`:

![Screenshot of disk in use metric](./assets/disk_in_use.png)

After clicking on `Done` you can copy the full query in your clipboard:

![Screenshot of query to copy](./assets/copy_query.png)

Open the configuration for the Datadog Monitor and review it a bit `cluster-config-files/datadog-monitor-disk.yaml`{{open}}. We are assigning a name to our monitor and a series of tags. We are missing the query, though. Edit the file with the query you copied from the notebook and adding "> 0.5" to it, to alert when it goes above 50%. The final file should look like this:

```
apiVersion: datadoghq.com/v1alpha1
kind: DatadogMonitor
metadata:
name: datadog-monitor-test
spec:
  query: "avg:system.disk.in_use{*} by {host} > 0.5"
  type: "metric alert"
  name: "Disk space on Kubernetes nodes"
  message: "We are running out of disk space!"
  tags:
    - "cluster_name:katacoda"
```

Let's apply it:

`kubectl apply -f cluster-config-files/datadog-monitor-disk.yaml`{{execute}}

