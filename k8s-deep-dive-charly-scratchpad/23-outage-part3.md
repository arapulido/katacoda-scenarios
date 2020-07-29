![Slack](./assets/slack3.png)

## Your mission: deploy a fix to the issue in the `discount-service` and reduce the latency to an healthy level

Can you interpret the pattern in the flame graph to classify the type of problem with the database query?

<details>
<summary>Hints</summary>

The problem is a lazy lookup on a relational database. 

</details>

Can you identify the code changes needed in `\assets\discounts.py` to fix the latency issue?

<details>
<summary>Hints</summary>

By changing the line:

discounts = Discount.query.all()

To the following:

```
discounts = Discount.query.options(joinedload('*')).all()
```

We eager load the `discount_type` relation on the `discount`, and can grab all information without multiple trips to the database. 

</details>

Let's deploy the fixed version by running `kubectl deploy -f ...`. 

Can you verify that the latency issue is no longer happening?

<summary>Hints</summary>

Go back to the [Service Overview](https://app.datadoghq.com/apm/service/store-frontend/rack.request) page and look how the latency of the app is going down. 

Go back to the [Traces page](https://app.datadoghq.com/apm/traces) and look at one of the traces from the fixed service, they should look like this:
![solved-nplus](./assets/solved-nplus.png)


## Your mission: create a Datadog Monitor to alert on high application latency

In order to get notify next time if the application latency goes above the accepted range, we will create a Datadog Monitor to automatically alert us.

Follow these steps to create the monitor that alerts if the service latency is above 3 seconds:
* In Datadog, click on Monitors (in the left-hand menu) and choose [New Monitor](https://app.datadoghq.com/monitors#/create)
* Click on "APM Monitor" to choose this monitor type
* Next, edit the monitor scope: choose "APM Metrics", and choose the service `store-frontend`
* For the alert conditions, choose the "Threshold Alert" and select to Alert when `p95 latency` is `above` 2000 ms over the last `5 minutes`.
* Quickly review the timeseries graph with the monitor threshold, and save the monitor

<details>
<summary>Hints</summary>
To quickly create the monitor, you can go to the [New Monitor](https://app.datadoghq.com/monitors#/create), and choose "Import Monitor from JSON".</br></br>Then, copy the content of the monitor from [TBD!! link to assets](./) and paste it in Datadog.
</details>

Since your company and SRE team established clear Service Level Objectives (SLOs). Let's make sure that we can track and achieve the defined target around application latency -- 

## Your mission: create a Datadog SLO to track your application latency target

Create a SLO that tracks your target for application latency. You can follow these steps:

* On the Datadog [SLO status page](https://app.datadoghq.com/slo), click on "New SLO +"
* Define the source as "Monitor based" and choose from the list the name of the monitor you created in the previous part
* Click on "New Target" and choose 99% as the Target, in a 7 days time window. 
* Click save, which will take you to your SLO page. Review that the status and error budget are looking good, now that we fixed the performance issue in the database query.