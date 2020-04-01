We have set up our Datadog Cluster Agent to also work as a HPA External Metrics server. That means that we can drive our scaling events based on any metric we have in our Datadog account.

Let's check what metrics do we have available by navigating to the [Metrics Summary in Datadog](https://app.datadoghq.com/metric/summary). Spend a bit of time checking the different metrics that we have available and try to understand what some of those are tracking. TIP: Clicking on any available metric in the Metrics Summary will show a description of the metric and the available tags for that metric.

As we discussed, the LETS (Latency, Errors, Traffic, Saturation) framework is a good place to start when we want to start tracking our application. We will scale our application using the latency we are seeing in the `store-frontend` service. Right now, our application is getting regular traffic coming from the deployment called `regular-traffic`. What latency is the service `store-frontend` experiencing? To answer that question we can navigate to the [Service Map](https://app.datadoghq.com/apm/map?env=ruby-shop) in Datadog and hover over the `store-frontend` service. What latency are we seeing?

TODO: Add screenshot

We are experiencing a latency of around 7 seconds and we want to keep it around those numbers, even if the traffic increases. For that, we are going to create a HPA object that uses the [`trace.rack.request.duration` metric](https://app.datadoghq.com/metric/explorer?live=true&exp_metric=trace.rack.request.duration&exp_scope=service%3Astore-frontend&exp_agg=min&exp_row_type=metric) and that will have 7 seconds as the limit to start scaling our deployment.

Create a file called `frontend-hpa-latency.yaml` by executing the following command: `touch frontend-hpa-latency.yaml`{{execute}} Open the newly created file in the editor and copy the following contents:

```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: frontendhpaduration
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
      metric:
        name: "trace.rack.request.duration.by.resource_service.100p"
        selector:
          matchLabels:
            service: store-frontend
      target:
        type: AverageValue
        averageValue: 7
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
  - type: External
    external:
      metric:
        name: "trace.rack.request.duration.by.resource_service.p100"
        selector:
          matchLabels:
            service: store-frontend
      target:
        type: AverageValue
        averageValue: 7

```

In this section we are specifying the metric that the HPA will use to drive the scaling events. In this case we are telling the HPA that when pods that are part of the Deployment `frontend` experience an average latency over 7 seconds, create a scaling event that will increase the number of replicas.


```
minReplicas: 1
maxReplicas: 3
```

In this section of the specification we are specifiying the minimum and maximum number of replicas for the target that we want. In this case we are telling the HPA controller that, even if the replicas are experiencing over 7 seconds of latency, to not go above 3 replicas.

Create the HPA object by applying the manifest: `kubectl apply -f frontend-hpa-latency.yaml`{{execute}}

Let's check that the Datadog Cluster Agent is now taking care of that HPA object. Execute the following command: `kubectl describe hpa frontendhpaduration`{{execute}} and make sure that you get the following object event: 

```
Events:
  Type     Reason                                         Age   From                       Message
  ----     ------                                         ----  ----                       -------
  Normal   Autoscaler is now handle by the Cluster-Agent  23s   datadog-cluster-agent
```

Finally, let's check that the Cluster Agent is getting the metric correctly by executing the agent status for the Cluster Agent: `kubectl exec -ti $(kubectl get pods -l app=datadog-cluster-agent -o jsonpath='{.items[0].metadata.name}') -- agent status`{{execute}} Browse the output and check that you get an output similar to this one:

```
External Metrics
----------------
    Total: 1
    Valid: 1

* horizontal pod autoscaler: default/frontendhpaduration
    Metric name: trace.rack.request.duration
    Labels:
    - service: store-frontend
    Value: 25.87385368347168
    Timestamp: 2020-03-30 10:44:30.000000 UTC
    Valid: true
```

That states that the Cluster Agent is correctly getting the value of the metric requested by our HPA object.