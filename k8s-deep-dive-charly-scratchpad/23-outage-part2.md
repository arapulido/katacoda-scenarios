![Slack](./assets/slack2.png)

## Your mission: understand the root cause for the high latency in `store-frontend`

In order to fix the problem, you would need to understand where the issue is and propose a solution. Use Datadog to find the root cause for the high latency.

You already know the service and the endpoint. Where would you look next? Is there an issue with the infrasructure such as low available resources? Maybe we need to scale up the deployment? or maybe our developers rolled out a new version which has a bug of some sort?

<details>
<summary>Hints</summary>

Analyzing a distributed trace in Datadog can expose the bottleneck and allows us to understand how to solve performance issues in our applications.

Go to the [Traces page](https://app.datadoghq.com/apm/traces) and use the left-hand facets to filter on:
** Duration larger than 5s
** Service: store-frontend

Click on one of the traces.

Investigate the flame graph, container metrics, application logs, and processes from each of the services involved in the request.

Can you spot the issue? 
</details>
<br/><br/>
<details>
<summary>Hints</summary>

It seems like there is a problem in how `discounts-service` is accessing the database:
![Date remapper](./assets/db-query.png)

It doesn't look an efficient way to query the database, can you find out why?

</details>