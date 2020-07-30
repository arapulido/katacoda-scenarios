## Your mission: create a Datadog Monitor to alert on high application latency

An important part of a good monitoring framework is alerting.  In order to get notify next time if the application latency goes above the accepted range, let's create a Datadog Monitor to automatically alert us if our service latency is unexpectedly high and causing a bad experience to our end-users.

In the previous step, you found out that `service:store-frontend` has a high latency and the reason why some users have started complaining that the application is slow.

Follow these steps to create the monitor that automatically trigger alerts if the latency of `store-frontend` service is higher than three seconds:

(note: in a real production environment, we would like latency to be much lower)

* In Datadog, click on Monitors (in the left-hand menu) and choose [New Monitor](https://app.datadoghq.com/monitors#/create)
* Click on "APM Monitor" to choose this monitor type
* Next, edit the monitor scope: choose "APM Metrics", and choose the service `store-frontend`
* For the alert conditions, choose the "Threshold Alert" and select to Alert when `p95 latency` is `above` 3 seconds over the last `5 minutes`.
* Quickly review the timeseries graph with the monitor threshold, and save the monitor

<details>
<summary>Hints</summary>
To quickly create the monitor, you can go to the [New Monitor](https://app.datadoghq.com/monitors#/create), and choose "Import Monitor from JSON".</br></br>Then, copy-paste the following JSON into Datadog:

```
{
	"name": "Service store-frontend has a high p95 latency on env:ruby-shop",
	"type": "metric alert",
	"query": "avg(last_5m):avg:trace.rack.request.duration.by.service.95p{env:ruby-shop,service:store-frontend} > 3",
	"message": "`ruby-shop` 95th percentile latency is too high.\n\n@store-frontend",
	"tags": [
		"service:store-frontend",
		"env:ruby-shop"
	],
	"options": {
		"renotify_interval": 0,
		"timeout_h": 0,
		"thresholds": {
			"critical": 3
		},
		"notify_no_data": false,
		"no_data_timeframe": 2,
		"notify_audit": false,
		"evaluation_delay": null
	}
}
```

</details>

Since your company and SRE team established clear Service Level Objectives (SLOs). Let's make sure that we can track and achieve the defined target around application latency -- 

## Your mission: create a Datadog SLO to track your application latency target

Create a SLO that tracks your target for application latency. You can follow these steps:

* On the Datadog [SLO status page](https://app.datadoghq.com/slo), click on "New SLO +"
* Define the source as "Monitor based" and choose from the list the name of the monitor you created in the previous part
* Click on "New Target" and choose 99% as the Target, in a 7 days time window. 
* Click save, which will take you to your SLO page. Review that the status and error budget are looking good, now that we fixed the performance issue in the database query.


### Complete this step by creating a Datadog Monitor and Datadog SLO that track the latency of the service `store-frontend`. Continue to the next step afterwards.