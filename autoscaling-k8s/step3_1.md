We are going to build a dashboard in Datadog that will help us visualize what is happening in our cluster throughout the rest of the workshop.

Click on Dashboards -> New Dashboard in the menu. Provide a name and select New Timeboard:

![Screenshot of New Dashboard](./assets/new_dashboard.png)

Click on "Add Graph" and select "Timeseries" as the type of graph.

For the first graph we are going to visualize the number of pod replicas we have for the `store-frontend` service. Select `kubernetes_state.deployment.replicas` as metric and filter by `kube_deployment:frontend`:

![Screenshot of replicas metric](./assets/frontend_replicas.png)

Save the graph and add another "Timeseries" graph to the dashboard. This time select `kubernetes.cpu.usage.total` as metric and `kube_deployment:frontend` as filter.

Save the graph and add another "Timeseries" graph to the dashboard. This time select `trace.rack.request.duration.by.service.99p` as metric and `service:store-frontend` as filter. Call it "p99 latency for the frontend service". 

Save the graph and add another "Timeseries" graph to the dashboard. This time select `trace.rack.request.hits` as metric and `service:store-frontend` as filter. Call it "Number of requests per minute for the frontend service". 

Save the graph and add another "Timeseries" graph to the dashboard. This time select `kubernetes.memory.usage` as metric and `kube_deployment:frontend` as filter. Save this graph and click on "Finish Editing" to save the full Dashboard. You should get a Dashboard similar to this:

![Screenshot of Dashboard](./assets/autoscaling_workshop_dashboard.png)

You can reference [Datadog's documentation on Dashboards](https://docs.datadoghq.com/dashboards/).