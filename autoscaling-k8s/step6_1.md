To use the Cluster Agent as External Metrics Server using the DatadogMetric object we will need to modify our Datadog Helm installation and set the `clusterAgent.metricsProvider.useDatadogMetrics` option to `true`. You can check the differences between our previous Helm chart values files and the one we are going to use now:

`diff -U3 k8s-manifests/datadog/datadog-helm-values-external-metrics.yaml k8s-manifests/datadog/datadog-helm-values-crd.yaml`{{execute}}

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY --set datadog.appKey=$DD_APP_KEY datadog/datadog -f k8s-manifests/datadog/datadog-helm-values-crd.yaml --version=2.16.6`{{execute}}

Wait until the Datadog agent is running by executing this command: `wait-cluster-agent.sh`{{execute}}

Once the pod is running, let's check that the metrics server now expects DatadogMetrics objects. Execute the following command: `kubectl exec -ti deploy/datadog-cluster-agent -- agent status | grep "Custom Metrics Server" -A3`{{execute}} If the Metrics Server now expects DatadogMetric objects, you should get the following output:

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
  query: avg:trace.rack.request.hits{service:store-frontend}.rollup(15).as_rate() 
</pre>

This is similar to the query we had on the previous step, but we are able to modify the time agreggation type and size (in this case 15 seconds), and we would be able to include functions or transform our metric to our rate. In our case, by adding `as_rate()` to our query, we will get the number of requests per second, which will be a more readable and useful value for our scaling events. 

Deploy the DatadogMetrics object by applying the `datadog-metric.yaml` manifest: `kubectl apply -f datadog-metric.yaml`{{execute}}

Check that the object was correctly created by executing: `kubectl get datadogmetric`{{execute}} You should get output similar to this:

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
      targetAverageValue: 1
</pre>

Deploy the HPA object by applying the `hpa-query.yaml` manifest: `kubectl apply -f hpa-query.yaml`{{execute}}

Start watching the DatadogMetric object, until it gets a value from Datadog and a status of `VALID=True`: `kubectl get datadogmetric -w`{{execute}}. Wait some minutes until you see `VALID=True`. Once you are done watching the object, type `Ctrl+C` to go back to the terminal.

```
NAME            ACTIVE   VALID   VALUE                 REFERENCES             UPDATE TIME
frontend-hits   True     True    0.13333333333333333   default/hitsexternal   54s
```

Let's generate some more fake traffic to force more than 1 request per second on average per replica. Execute the following command: `kubectl apply -f k8s-manifests/autoscaling/spike-traffic.yaml`{{execute}}

Let's watch the HPA object to check when something changes: `kubectl get hpa hitsexternal -w`{{execute}}. Wait some minutes to see the replicas number going up. Once you are done watching the object, type `Ctrl+C` to go back to the terminal.

```
NAME           REFERENCE             TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
hitsexternal   Deployment/frontend   134m/1 (avg)    1         3         1          13m
hitsexternal   Deployment/frontend   967m/1 (avg)    1         3         1          15m
hitsexternal   Deployment/frontend   1100m/1 (avg)   1         3         1          15m
hitsexternal   Deployment/frontend   534m/1 (avg)    1         3         2          15m
hitsexternal   Deployment/frontend   550m/1 (avg)    1         3         2          16m
hitsexternal   Deployment/frontend   489m/1 (avg)    1         3         2          16m
hitsexternal   Deployment/frontend   1017m/1 (avg)   1         3         2          17m
hitsexternal   Deployment/frontend   2134m/1 (avg)   1         3         2          17m
hitsexternal   Deployment/frontend   1423m/1 (avg)   1         3         3          18m
```

Did the deployment scale? Navigate in Datadog to the Autoscaling Workshop dashboard you created in a previous step of this course. Can you see the the correlation between the increase of requests and the increase in number of replicas?

Before moving to the next step, let's clean up our HPA and let's redeploy the Ecommerce application, so we go back to 1 replica. Execute the following command: `kubectl delete -f k8s-manifests/autoscaling/spike-traffic.yaml && kubectl delete hpa hitsexternal && kubectl delete datadogmetric frontend-hits && kubectl apply -f k8s-manifests/ecommerce-app`{{execute}}