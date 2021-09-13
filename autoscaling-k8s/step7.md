In order to be able to deploy Watermark Pod Autoscaler objects (WPAs) we first need to deploy the Custom Resource Definition and the controller, as these are not part of a default Kubernetes distribution.

Let's create the CRDs first. Execute the following command: `kubectl apply -f k8s-manifests/watermarkpodautoscaler/crd/`{{execute}} This will create a new WatermarkPodAutoscaler object in the Kubernetes API.

Let's apply now the manifests that deploy the WPA controller. This controller will watch for new WPA objects created and create scaling events based on the metrics. Execute the following command: `kubectl apply -f k8s-manifests/watermarkpodautoscaler/`{{execute}}

Check that the `watermarkpodautoscaler` is running correctly: `kubectl get pod $(kubectl get pods -l name=watermarkpodautoscaler -o jsonpath='{.items[0].metadata.name}')`{{execute}}

Then, we will need to modify our Datadog Helm installation and set the `clusterAgent.metricsProvider.wpaController` option to `true` to configure the Cluster Agent to work with WPA objects. You can check the differences between our previous Helm chart values files and the one we are going to use now:

`diff -U3 k8s-manifests/datadog/datadog-helm-values-crd.yaml k8s-manifests/datadog/datadog-helm-values-wpa.yaml`{{execute}}

`helm upgrade datadog --set datadog.apiKey=$DD_API_KEY --set datadog.appKey=$DD_APP_KEY datadog/datadog -f k8s-manifests/datadog/datadog-helm-values-wpa.yaml --version=2.16.6`{{execute}}

Wait until the Datadog agent is running by executing this command: `wait-cluster-agent.sh`{{execute}}

Similar to the HPA example, we will create a WPA object that will scale our `frontend` deployment based on the number of requests the service is getting.

We are going to create a new file called `frontend-wpa.yaml` (file creation happens automatically by clicking below on "Copy to Editor"):

<pre class="file" data-filename="frontend-wpa.yaml" data-target="replace">
apiVersion: datadoghq.com/v1alpha1
kind: WatermarkPodAutoscaler
metadata:
  name: frontend-wpa-hits
spec:
  downscaleForbiddenWindowSeconds: 60
  upscaleForbiddenWindowSeconds: 30
  minReplicas: 1
  maxReplicas: 5
  scaleTargetRef:
    kind: Deployment
    apiVersion: apps/v1
    name: frontend
  metrics:
  - external:
      highWatermark: "10"
      lowWatermark: "1"
      metricName: "trace.rack.request.hits"
      metricSelector:
        matchLabels:
          service: store-frontend
    type: External
  tolerance: 0.01
</pre>

Create the WPA object by applying the manifest: `kubectl apply -f frontend-wpa.yaml`{{execute}}

Let's drilldown on each section to understand what's going on:

```
scaleTargetRef:
  apiVersion: apps/v1
  kind: Deployment
  name: frontend
```

In this section we are specifying the pods that will be the target for the horizontal scaling. In this case, we are specifying the pods that are part of the Deployment called `frontend`.

```
metrics:
- external:
    highWatermark: "10"
    lowWatermark: "1"
    metricName: "trace.rack.request.hits"
    metricSelector:
    matchLabels:
        service: store-frontend
  type: External
```

In this section we are specifying the metric that the WPA will use to drive the scaling events. In this case we are telling the WPA that when pods that are part of the Deployment `frontend` gets more than 10 requests every 10 seconds (remember that this metric has an internal of 10 seconds), to create a scaling event that will increase the number of replicas, but, once the number or requests start going down, to not scale down the deployment until the number of requests every 10 seconds is less than 1.

```
minReplicas: 1
maxReplicas: 5
```

In this section of the specification we are specifiying the minimum and maximum number of replicas for the target that we want. In this case we are telling the WPA controller that, even if the replicas are experiencing more than 10 requests every 10 seconds, to not go above 5 replicas.

Other options in our manifest:

 * `downscaleForbiddenWindowSeconds: 60`: Wait 60 seconds after a scaling event before scaling down
 * `upscaleForbiddenWindowSeconds: 30`: Wait 30 seconds after a scaling event before scaling up

As in the previous step we enabled DatadogMetric for the Cluster Agent deployment, now the Cluster Agent will create automatically a DatadogMetric object for any HPA or WPA object created with an external metric, for backwards compatibility.

Let's watch until the DatadogMetric object is created and that it gets a valid value by executing the following command: `kubectl get datadogmetric -w`{{execute}} Once you are done watching the object, type `Ctrl+C` to go back to the terminal. You should get output similar to this one:

```
controlplane $ kubectl get datadogmetric -w
NAME                                                ACTIVE   VALID   VALUE   REFERENCES                     UPDATE TIME
dcaautogen-9e5050b2c142733b0a5abb2b2b00cbe29722bc   True     False   0       default/frontend-wpa-latency   30s
dcaautogen-9e5050b2c142733b0a5abb2b2b00cbe29722bc   True     True    2       default/frontend-wpa-latency   79s
```

That states that the Cluster Agent is correctly getting the value of the metric requested by our WPA object. Let's get the WPA object to see if the metric is being reflected there. Execute the following command: `kubectl get wpa frontend-wpa-hits`{{execute}}:

```
NAME                   VALUE   HIGH WATERMARK   LOW WATERMARK   AGE     MIN REPLICAS   MAX REPLICAS   DRY-RUN
frontend-wpa-hits      1667m   10               1               5m44s   1              5
```

Let's generate more traffic to force the creation of several replicas. Create the traffic by applying the following manifest: `kubectl apply -f k8s-manifests/autoscaling/spike-traffic.yaml`{{execute}}

Let's watch the frontend pods to see if they increase: `kubectl get deployment frontend -w`{{execute}}. Remember to type `Ctrl+C` to go back to the terminal once you have seen the deployment scaling.

Did the deployment scale? Navigate in Datadog to the Autoscaling Workshop dashboard you created in a previous step of this course. Can you see the the correlation between the increase in the p99 latency and the increase in number of replicas? Did you find any differences on how the deployment scaled with the regular HPA and how it is scaling with the WPA? (Hint: you can see those steps related to scaling velocity, for example)

![Screenshot of WPA Dashboard](./assets/dashboard-wpa.png)

Remove the spike in traffic by executing: `kubectl delete -f k8s-manifests/autoscaling/spike-traffic.yaml`{{execute}}

Watch again the the frontend pods to see if they decrease: `kubectl get deployment frontend -w`{{execute}} Why aren't they decreasing? Tip: Check the metric value and our low watermark. Is the metric value below our low watermark to create the scaling down event?

You can obtain more information about the different scaling events that happened by describing the WPA object: `kubectl describe wpa frontend-wpa-hits`{{execute}}

For other WPA options and algorithm documentation you can check the [WPA documentation](https://github.com/DataDog/watermarkpodautoscaler).
