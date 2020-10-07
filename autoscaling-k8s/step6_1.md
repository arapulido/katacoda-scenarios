
Before we enable DatadogMetrics in our cluster agent deployment, we need to create the CRD objects in our Kubernetes API. Deploy the DatadogMetrics CRD by applying the `datadog/datadogmetrics_crd.yaml` manifest: `kubectl apply -f datadog/datadogmetrics_crd.yaml`{{execute}}

Now, we will need to edit the Cluster Agent manifest to enable working with DatadogMetrics objects. Open the file called `datadog/datadog-cluster-agent.yaml`{{open}} with the editor and find the following section:

```
- name: DD_EXTERNAL_METRICS_PROVIDER_USE_DATADOGMETRIC_CRD
  value: 'false'
```

Edit the value to `true` and re-apply the manifest by executing `kubectl apply -f datadog/datadog-cluster-agent.yaml`{{execute}}


Let's check that the change had effect by executing the cluster agent status command: `kubectl exec -ti $(kubectl get pods -l app=datadog-cluster-agent -o jsonpath='{.items[0].metadata.name}') -- agent status | grep "Custom Metrics Server" -A3`{{execute}} You should get an output similar to this:

```
Custom Metrics Server
=====================
  External metrics provider uses DatadogMetric - Check status directly from Kubernetes with: `kubectl get datadogmetric`
```

Now, before creating the HPA object, we are going to create a DatadogMetric object with a more complex query.

We are going to create a new file called `datadog-metric.yaml` (file creation happens automatically by clicking below on "Copy to Editor"):

<pre class="file" data-filename="datadog-metric.yaml" data-target="replace">
apiVersion: datadoghq.com/v1alpha1
kind: DatadogMetric
metadata:
  name: frontend-hits
spec:
  query: avg:trace.rack.request.hits{env:ruby-shop,service:store-frontend}.as_count().rollup(sum, 60)
</pre>

Deploy the DatadogMetrics object by applying the `datadog-metric.yaml` manifest: `kubectl apply -f datadog-metric.yaml`{{execute}}

Check that the object was correctly created by executing: `kubectl get datadogmetric`{{execute}} You should get an output similar to this:

```
NAME            ACTIVE   VALID   VALUE   REFERENCES   UPDATE TIME
frontend-hits
```

Now, we are going to create the HPA object, referencing the DatadogMetrics object. We are going to create a new file called `hpa-query.yaml` (file creation happens automatically by clicking below on "Copy to Editor"): 

<pre class="file" data-filename="hpa-query.yaml" data-target="replace">
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: hitsexternal 
spec:
  minReplicas: 1
  maxReplicas: 3
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend 
  metrics:
  - type: External
    external:
      metricName: datadogmetric@default:frontend-hits
      targetAverageValue: 10
</pre>

Deploy the HPA object by applying the `hpa-query.yaml` manifest: `kubectl apply -f hpa-query.yaml`{{execute}}

Start watching the DatadogMetric object, until it gets a value from Datadog and a status of `VALID=True`: `kubectl get datadogmetric -w`{{execute}}. Wait some minutes until you see `VALID=True`. Once you are done watching the object, type `Ctrl+C` to go back to the terminal.

```
NAME            ACTIVE   VALID   VALUE   REFERENCES   UPDATE TIME
frontend-hits   True     False   0                    33s
frontend-hits   True     True    6                    101s
```

Let's generate some more fake traffic to force the average number of requests in 60 seconds to go above 10. Execute the following command: `kubectl apply -f k8s-manifests/autoscaling/spike-traffic.yaml`{{execute}}

Let's watch the HPA object to check when something changes: `kubectl get hpa hitsexternal -w`{{execute}}. Wait some minutes to see the replicas number going up. Once you are done watching the object, type `Ctrl+C` to go back to the terminal.

Did the deployment scale? Navigate in Datadog to the Autoscaling Workshop dashboard you created in a previous step of this course. Can you see the the correlation between the increase of requests and the increase in number of replicas?

Before moving to the next step, let's clean up our HPA and let's redeploy the Ecommerce application, so we go back to 1 replica. Execute the following command: `kubectl delete -f k8s-manifests/autoscaling/spike-traffic.yaml && kubectl delete hpa hitsexternal && kubectl delete datadogmetric frontend-hits && kubectl apply -f k8s-manifests/ecommerce-app`{{execute}}