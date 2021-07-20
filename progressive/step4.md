As we have our application up and running and we have deployed Datadog to it, we should start seeing data in our Datadog account. Let's browse around.

## Live Containers

Open the [Live Containers page](https://app.datadoghq.com/containers) and browse around:

![Screenshot of the Live Containers page](./assets/live_containers.png)

In the Live Containers page you can have all the information about your Kubernetes cluster in a single place. For example, if you wanted to have a visualization of all Deployments in your cluster, grouped by namespace, you could click on "Deployments", then group by `kube_namespace` and then click on "Cluster Map". [This link](https://app.datadoghq.com/orchestration/map/deployment?groups=kube_namespace&metric=deployment.uptime&paused=false) will send you directly to that visualization:

![Screenshot of the Cluster Map page](./assets/cluster_map.png)

Continue to browse around the Live Containers page. What other information are you finding?

## Service page

Our application is already instrumented for distributed tracing, so any request made to the application will generate a trace and a set of spans. We are also generating fake traffic to the application, to ensure we get enough data.

Open the [Services list](https://app.datadoghq.com/apm/services?env=progressive). What services do you see? What type of information are we getting for each of those?

![Screenshot of the Service List page](./assets/service_list.png)

Click now on "Service Map", you can get the same information but in a visual way, being able to quickly understand what services talk to what services in our application:

![Screenshot of the Service Map page](./assets/service_map.png)

Hover over the different services to visualize traffic and latency.
