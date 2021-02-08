We have now set the HTTP check for the `nginx` service and the NGINX check for the `nginx` pods. This is fairly easy to do, as the `nginx` service matches just 1 deployment, so keeping track of what NGINX pods we need to annotate is simple enough.

But a [Service in Kubernetes](https://kubernetes.io/docs/concepts/services-networking/service/#service-resource) is just a virtual load balancer that balances traffic between several [Endpoints](https://kubernetes.io/docs/reference/kubernetes-api/services-resources/endpoints-v1/). What if we don't know what endpoints will be part of our load balanced service? These could be several Kubernetes deployments, single pods, external services, etc. In those cases, enabling the NGINX check for every single Endpoint can be a bit more challenging.

To make this use case easier, we can enable [Endpoint Checks](https://docs.datadoghq.com/agent/cluster_agent/endpointschecks/). With Endpoint Checks, instead of annotating the deployment, we will add the endpoint annotations directly into the Service object description and the Cluster Agent will resolve this automatically, dispatching checks for all the different available endpoints.

We have prepared a file with the right annotations. Open the file `cluster-checks-files/nginx/nginx-service-endpoints.yaml`{{open}} and check the annotations to enable the HTTP check and the NGINX endpoint checks in the Service definition.

You can check the difference between both service descriptions running this command: `diff -U6 cluster-checks-files/nginx/nginx-service-annotations.yaml cluster-checks-files/nginx/nginx-service-endpoints.yaml`{{execute}}

Let's apply those changes:

`kubectl apply -f cluster-checks-files/nginx/nginx-service-endpoints.yaml`{{execute}}

Let's wait until the NGINX pods get restarted (type `Ctrl+C` to return to the terminal when done): `kubectl get deploy nginx -w`{{execute}}

Once the NGINX pods are running, let's run the `clusterchecks` command in the Cluster Agent pod:

`kubectl exec -ti deploy/datadog-cluster-agent -- agent clusterchecks`{{execute}}

You should get an output similar to this:

```
===== 3 Pod-backed Endpoints-Checks scheduled =====

=== nginx check ===
Configuration provider: kubernetes-endpoints
Configuration source: kube_endpoints:kube_endpoint_uid://default/nginx/
Instance ID: nginx:My Nginx Service Endpoints:fea12b83c2ac31d2
name: My Nginx Service Endpoints
nginx_status_url: http://10.44.0.6:8080/nginx_status
tags:
- kube_namespace:default
- kube_endpoint_ip:10.44.0.6
- kube_service:nginx
- cluster_name:katacoda
- kube_cluster_name:katacoda
~
Init Config:
{}
Auto-discovery IDs:
* kube_endpoint_uid://default/nginx/10.44.0.6
* kubernetes_pod://fa1da017-62ac-4dcf-bc74-41bcc10395cf
State: dispatched to node01
===
[...]
```

And if we now run the `agent status` command in the node agent, we will see the nginx checks running there:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:.metadata.name --field-selector spec.nodeName=node01) -- agent status`{{execute}}

```
nginx (3.8.0)
-------------
  Instance ID: nginx:My Nginx Service Endpoints:a91e5f9a9ae19357 [OK]
  Configuration Source: kube_endpoints:kube_endpoint_uid://default/nginx/
  Total Runs: 18
  Metric Samples: Last Run: 7, Total: 126
  Events: Last Run: 0, Total: 0
  Service Checks: Last Run: 1, Total: 18
  Average Execution Time : 6ms
  Last Execution Date : 2021-02-08 11:32:43.000000 UTC
  Last Successful Execution Date : 2021-02-08 11:32:43.000000 UTC
  
  Instance ID: nginx:My Nginx Service Endpoints:b0bf5f37b01bc443 [OK]
  Configuration Source: kube_endpoints:kube_endpoint_uid://default/nginx/
  Total Runs: 17
  Metric Samples: Last Run: 7, Total: 119
  Events: Last Run: 0, Total: 0
  Service Checks: Last Run: 1, Total: 17
  Average Execution Time : 15ms
  Last Execution Date : 2021-02-08 11:32:29.000000 UTC
  Last Successful Execution Date : 2021-02-08 11:32:29.000000 UTC
  
  Instance ID: nginx:My Nginx Service Endpoints:ec258176e6231401 [OK]
  Configuration Source: kube_endpoints:kube_endpoint_uid://default/nginx/
  Total Runs: 17
  Metric Samples: Last Run: 7, Total: 119
  Events: Last Run: 0, Total: 0
  Service Checks: Last Run: 1, Total: 17
  Average Execution Time : 7ms
  Last Execution Date : 2021-02-08 11:32:36.000000 UTC
  Last Successful Execution Date : 2021-02-08 11:32:36.000000 UTC
```
