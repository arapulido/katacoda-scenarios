We are going to build a dashboard in Datadog that will help us visualize what is happening in our cluster throughout the rest of the workshop.

Click on Dashboards -> New Dashboard in the menu. Provide a name and select New Timeboard:

![Screenshot of New Dashboard](autoscaling-k8s/assets/new_dashboard.png)

Click on "Add Graph" and select "Timeseries" as the type of graph.

For the first graph we are going to visualize the number of pod replicas we have for the `store-frontend` service. Select `kubernetes_state.deployment.replicas` as metric and filter by `deployment:frontend`:

![Screenshot of replicas metric](autoscaling-k8s/assets/frontend_replicas.png)

Save the graph and add another "Timeseries" graph to the dashboard. This time select `kubernetes.cpu.user.total` as metric and `kube_deployment:frontend` as filter.

Save the graph and add another "Timeseries" graph to the dashboard. This time select `kubernetes.memory.usage` as metric and `kube_deployment:frontend` as filter.

Save the graph and add another "Timeseries" graph to the dashboard. This time select `trace.rack.request.duration.by.resource_service.99p` as metric and `service:store-frontend` as filter. Call it "p99 latency for the frontend service". Save this graph and click on "Finish Editing" to save the full Dashboard. You should get a Dashboard similar to this:

![Screenshot of Dashboard](autoscaling-k8s/assets/autoscaling_workshop_dashboard.png)

You can reference [Datadog's documentation on Dashboards](https://docs.datadoghq.com/dashboards/).