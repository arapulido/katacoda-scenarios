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

We eager load the discount_type relation on the discount, and can grab all information without multiple trips to the database:

</details>

Let's deploy the fixed version by running `kubectl deploy -f ...`. After the deployment is done, go back to the [Service Overview](https://app.datadoghq.com/apm/service/store-frontend/rack.request) page and look how the latency of the app is going down. 