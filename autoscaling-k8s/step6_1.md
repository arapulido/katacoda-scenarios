
Deploy the DatadogMetrics CRD by applying the `datadog/datadogmetric_crd.yaml` manifest: `kubectl apply -f datadog/datadogmetric_crd.yaml`{{execute}}

<pre class="file" data-filename="datadog-metric.yaml" data-target="replace">
apiVersion: datadoghq.com/v1alpha1
kind: DatadogMetric
metadata:
  name: frontend-hits 
spec:
  query: avg:trace.rack.request.hits{service:store-frontend}.rollup(120)
</pre>


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
      targetAverageValue: 4
</pre>


