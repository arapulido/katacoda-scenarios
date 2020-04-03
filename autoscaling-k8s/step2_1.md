Our Ecommerce application is already instrumented for distributed tracing and is receiving regular traffic through the `regular-traffic` deployment. Let's browse a bit what data we are getting in Datadog already.

## Host Map

Navigate to the [Host Map in Datadog](https://app.datadoghq.com/infrastructure/map). This visualization will show you all virtual and physical nodes where the Datadog agent is running. If everything went well, you should see a node called `node1` running some applications like the `datadog-agent`, `coredns`, etc:

![Screenshot of Node01](autoscaling-k8s/assets/node01.png)

Clicking on that host will show some system metrics from it, like CPU utilization.

## Containers

From the Host Map, clicking on the dropdown in the upper right that reads `Hosts` you can select `Containers` and you will get a visualization of all the containers that are running in your infrastructure:

![Screenshot of Drowpdown](autoscaling-k8s/assets/containers_dropdown.png)
![Screenshot of Containers](autoscaling-k8s/assets/containers.png)

## Service Map

As our application is receiving regular traffic and it is instrumented for APM, we should start seeing some traces arriving to Datadog. Those traces are used to build a diagram of our application. You can check it navigating to the [Service Map](https://app.datadoghq.com/apm/map):

![Screenshot of Service Map](autoscaling-k8s/assets/service_map.png)

Hover over the map, what data are we getting from the different services?

Click on one of the services and select "View service overview" from the contextual menu. What type of information do we have available in the Service Overview page?