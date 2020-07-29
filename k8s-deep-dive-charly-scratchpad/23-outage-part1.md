... 24 days later ...

PLACEHOLDER - show an image of a slack conversation between two people
John: We are getting many support tickets recently
Sarah: What's going on?
John: It seems like many users are complaining that the application is super slow

## Your mission: identify which part of the application is slow

Try to find the relevant pages in Datadog that will give you a clue of where the slowness issue may be, so you can start the troubleshooting from. 

Should you start looking at infrastructure metrics, application logs, or maybe something else?

<details>
<summary>Hints</summary>

An high application latency is usually a good indicator for a performance issue. Since we received complaints from end-users, we know that the issue lies in one of the services that users interact with (directly or indirectly). Hover mouse over each of the services to find the service with a problematic latency. 

The [Service Map page](https://app.datadoghq.com/apm/map) can give you a clear picture of each application service performance. Hover 
</details>

<details>
<summary>Hints</summary>

The service `store-frontend` has a latency of more than a few seconds. Click on it and choose [View Service Overview](https://app.datadoghq.com/apm/service/store-frontend/rack.request) to look at the application performance metrics more closely. You can scroll down to the Endpoints section to find the problematic endpoint.

</details>
