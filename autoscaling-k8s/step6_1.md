
Deploy the DatadogMetrics CRD by applying the `datadog/datadogmetrics_crd.yaml` manifest: `kubectl apply -f datadog/datadogmetrics_crd.yaml`{{execute}}

<pre class="file" data-filename="datadog-metric.yaml" data-target="replace">
apiVersion: datadoghq.com/v1alpha1
kind: DatadogMetric
metadata:
  name: frontend-hits
spec:
  query: avg:trace.rack.request.hits{env:ruby-shop,service:store-frontend}.as_count().rollup(sum, 60)
</pre>

Deploy the DatadogMetrics object by applying the `datadog-metric.yaml` manifest: `kubectl apply -f datadog-metric.yaml`{{execute}}


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

