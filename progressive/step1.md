Wait some minutes until your environment is setup. Once it is setup, you will see the following message in your terminal:`OK, the training environment is installed and ready to go.`

To not use your production environment, we have created a new Datadog account for you. You should see your credentials in the terminal:

```
A Datadog account has been created for you.
You can login at http://app.datadoghq.com using
the following credentials:

Username:       <username>
Password:       <password>

Use these credentials to login at http://app.datadoghq.com
This account will expire in 4 days..
A new account will be created at that time.
```

You can always retrieve again these credentials by running this command: `creds`{{execute}}.

We will be deploying Datadog in our cluster. For that we need to retrieve the API key for our Datadog organization. To make things easier we have already injected the Datadog API key of your newly created Datadog account in an environment variable. Check that it has a value by executing `echo $DD_API_KEY`{{execute}}

<details>
<summary>If $DD_API_KEY didn't have a value, or you want to use a different Datadog org, click here for an alternative step</summary>

Log into [Datadog](https://app.datadoghq.com/) and navigate to the [API settings page](https://app.datadoghq.com/account/settings#api) to reveal your API key.

![Screenshot of API Keys area](./assets/api_key.png)

Export your API key in an environment variable:

`export DD_API_KEY=<YOUR_DATADOG_API_KEY>`{{copy}}

Check that your API key has been successfully exported by running this command: `echo $DD_API_KEY`{{execute}}. You should get the same value that you copied from the Datadog web application.
</details>

Once the environment is ready, you can check the different cluster nodes and the Kubernetes version they are running by executing this command: `kubectl get nodes`{{execute}}

```
NAME           STATUS   ROLES    AGE   VERSION
controlplane   Ready    master   17m   v1.19.4
node01         Ready    <none>   17m   v1.19.3
```