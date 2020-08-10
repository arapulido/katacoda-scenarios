Our Ecommerce application is already instrumented for distributed tracing and is receiving regular traffic through the `regular-traffic` deployment (inside the `fake-traffic` namespace). Let's browse a bit what data we are getting in Datadog already.

Note: Some of the data (particularly container data) may take up to 5-10 minutes to show up

## Host Map

Navigate to the [Infrastructure List in Datadog](https://app.datadoghq.com/infrastructure). This list will show you all virtual and physical nodes where the Datadog agent is running. If everything went well, you should see a node called `node01` running some applications like the `datadog-agent`, `coredns`, etc:

![Screenshot of Node01](./assets/node01.png)

Clicking on that host will show some system metrics from it, like CPU utilization.

## Service Map

As our application receives traffic and is instrumented for APM, we should start seeing some traces arriving within Datadog. Those traces are used to build a diagram of our application’s activity. You can view this diagram by navigating to the [Service Map](https://app.datadoghq.com/apm/map):

![Screenshot of Service Map](./assets/service_map.png)

Hover over the map, what data are we getting from the different services?

Click on one of the services and select "View service overview" from the contextual menu. What type of information do we have available in the Service Overview page?

## Containers

Navigate now to the [Containers List](https://app.datadoghq.com/containers) under Infrastructure and you will get a list of all the containers that are running in your Kubernetes cluster:

![Screenshot of Containers](./assets/containers.png)

Can you figure out how to group those containers by namespace?
