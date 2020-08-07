... 24 days later ...

![Slack](./assets/slack1.png)

Good news -- by now, all your application services are fully monitored with Datadog, so we should be able to investigate and fix the issue.

## Your mission: identify which part of the application is slow

Start by trying to reproduce. Navigate to the E-commerce app and try to see if some pages or requests are slower than other and if you spot latency in critical spots.

Then, try to find the relevant pages in Datadog that will give you a clue of where the slowness issue may be.

Should you start looking at infrastructure metrics, application logs, or maybe something else?

If you are not fully familiar with all the pages in Datadog, here is a short list of some of the relevant pages you can find in the left-hand menu:

* [Infrastructure -> Containers](https://app.datadoghq.com/containers) - real-time visibility into all containers across your environment.
* [Infrastructure -> Processes](https://app.datadoghq.com/process) - real-time visibility of the most granular elements in a deployment.
* [Dashboards -> Dashboard list](https://app.datadoghq.com/dashboard) - view all the available integration dashboards (created by Datadog) and custom dashboards (created by users in your organization)
* [APM -> Service Map](https://app.datadoghq.com/apm/map) - decomposes your application into all its component services and draws the observed dependencies between these services in real time, so you can identify bottlenecks and understand how data flows through your architecture.
* [APM -> Traces](https://app.datadoghq.com/apm/traces) - View all traces from your applications, or view an individual trace to see all of its spans and associated metadata. Each trace can be viewed either as a flame graph or as a list (grouped by service or host).
* [Log Explorer](https://app.datadoghq.com/logs) -  your home base for logs-based troubleshooting and exploration.

Try to spend some time on each page while keeping in mind that your goal is to identify which part(s) of your application is slow and why.

<details>
<summary>Hint 1</summary>

A high application latency is usually a good indicator for a performance issue. Since we received complaints from end-users, we know that the issue involves at least one service that end-users interact with (directly or indirectly).

The [Service Map page](https://app.datadoghq.com/apm/map) can give you a clear picture of each application service performance. Hover your mouse over each of the services to find the service with a problematic latency, and correlate that with the # of requests each service receives and emits to identify the bottleneck.
</details>
<br/><br/>

<details>
<summary>Hint 2</summary>

The service `store-frontend` has a latency of more than a few seconds. Click on it and choose [View Service Overview](https://app.datadoghq.com/apm/service/store-frontend/rack.request) to look at the application performance metrics more closely. You can scroll down to the Endpoints section to find the problematic endpoint.

</details>

Once you have identified which data path is taking the longest time, move on to the next part.

<details>
<summary>Answer</summary>
We can see a high latency on the `store-frontend` service, but the service that stands up is the advertisement one.
Indeed, looking at a trace for the `store-frontend`, we spend more than 30% of the time in the advertisement service.

![Discount Service](./assets/outage1_ads.png)
</details>
