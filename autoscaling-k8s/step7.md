In order to be able to deploy Watermark Pod Autoscaler objects (WPAs) we first need to deploy the Custom Resource Definition and the controller, as these are not part of a default Kubernetes distribution.

Let's create the CRDs first. Execute the following command: `kubectl apply -f k8s-manifests/watermarkpodautoscaler/crd/`{{execute}} This will create a new WatermarkPodAutoscaler object in the Kubernetes API. Let's check that the object type is now available by running the following command: `kubectl get wpa`{{execute}} You shouldn't get an error and you should get the following output:

```
No resources found in default namespace.
```

Let's apply now the manifests that deploy the WPA controller. This controller will watch for new WPA objects created and create scaling events based on the metrics. Execute the following command: `kubectl apply -f k8s-manifests/watermarkpodautoscaler/`{{execute}}

Check that the `watermarkpodautoscaler` is running correctly: `kubectl get pod $(kubectl get pods -l name=watermarkpodautoscaler -o jsonpath='{.items[0].metadata.name}')`{{execute}}

Now, we will need to edit the Cluster Agent manifest to enable working with WPA objects. Open the file called `datadog/datadog-cluster-agent.yaml` with the editor and find the following section:

```
- name: DD_EXTERNAL_METRICS_PROVIDER_WPA_CONTROLLER
  value: 'false'
```

Edit the value to `true` and re-apply the manifest by executing `kubectl apply -f datadog/datadog-cluster-agent.yaml`{{execute}}

Similar to the HPA example, we will create a WPA object that will scale our `frontend` deployment based on the p99 latency that the service experiences. Create a file called `frontend-wpa.yaml` by executing the following command: `touch frontend-wpa.yaml`{{execute}} Open the newly created file with the editor and copy the following content:

```
apiVersion: datadoghq.com/v1alpha1
kind: WatermarkPodAutoscaler
metadata:
  name: frontend-wpa-latency
spec:
  downscaleForbiddenWindowSeconds: 60
  upscaleForbiddenWindowSeconds: 30
  scaleDownLimitFactor: 30
  scaleUpLimitFactor: 50
  minReplicas: 1
  maxReplicas: 9
  scaleTargetRef:
    kind: Deployment
    apiVersion: apps/v1
    name: frontend
  metrics:
  - external:
      highWatermark: "9"
      lowWatermark: "2"
      metricName: "trace.rack.request.duration.by.service.99p"
      metricSelector:
        matchLabels:
          service: store-frontend
    type: External
  tolerance: 0.01
```

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
    highWatermark: "9"
    lowWatermark: "2"
    metricName: "trace.rack.request.duration.by.service.99p"
    metricSelector:
    matchLabels:
        service: store-frontend
  type: External
```

In this section we are specifying the metric that the WPA will use to drive the scaling events. In this case we are telling the WPA that when pods that are part of the Deployment `frontend` experience an average p99 latency over 8 seconds, to create a scaling event that will increase the number of replicas, but, once the p99 latency starts going down, to not scale down the deployment until the p99 latency is less than 2 seconds.

```
minReplicas: 1
maxReplicas: 9
```

In this section of the specification we are specifiying the minimum and maximum number of replicas for the target that we want. In this case we are telling the HPA controller that, even if the replicas are experiencing over 9 seconds of p99 latency, to not go above 3 replicas.

Create the HPA object by applying the manifest: `kubectl apply -f frontend-wpa.yaml`{{execute}}

Let's generate a lot of traffic to force the creation of several replicas. Create the traffic applying the following manifest: `kubectl apply -f autoscaling/spike-traffic.yaml`{{execute}}
