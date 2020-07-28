We are now going to deploy Datadog in our cluster to start monitoring our infrastructure and applications.

Log into [Datadog](https://app.datadoghq.com/) and navigate to the [API settings page](https://app.datadoghq.com/account/settings#api) to reveal your API key.

![Screenshot of API Keys area](./assets/api_key.png)

Then, add your Datadog API key to the secrets. You can do this by executing the following command in the terminal:

`kubectl create secret generic datadog-secret --from-literal api-key=<YOUR_DATADOG_API_KEY>`{{copy}}

This will create a Kubernetes secret to make sure the Datadog agent is able to send data to your Datadog account.

Check that the secret has been correctly created by running the following command: `kubectl get secret datadog-secret`{{execute}} You should get an output similar to the following:

```
NAME             TYPE      DATA      AGE
datadog-secret   Opaque    1         8s
```

To deploy the Datadog agent, first we need to create the service account that will be used by the agent and give it the right RBAC persmissions.

In the editor, open the file called `datadog/serviceaccount.yaml`{{open}} and browse it a bit. You can see that we are going to create a service account called `datadog-agent` and give it some permissions to the Kubernetes API through a ClusterRole and a ClusterRoleBinding. You can learn more about RBAC in [the official Kuberentes documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).

Create the service account, the ClusterRole and the ClusterRoleBinding by applying the `datadog/serviceaccount.yaml` manifest: `kubectl apply -f datadog/serviceaccount.yaml`{{execute}}

Finally, we will deploy the Datadog agent. In the editor, open the file called `datadog/datadog-agent.yaml`{{open}} and explore the different options we have set up for our agent. Can you tell what options set up APM and log collection?

Deploy the Datadog agent DaemonSet applying the `datadog/datadog-agent.yaml` manifest: `kubectl apply -f datadog/datadog-agent.yaml`{{execute}}

Wait until the Datadog agent is running by executing this command: `wait-datadog.sh`{{execute}}

Once the `datadog-agent` pod is running, let's check its status by running the following command: `kubectl exec -ti $(kubectl get pods -l app=datadog-agent -o jsonpath='{.items[0].metadata.name}') -- agent status`{{execute}} Browse the output. What checks is the Datadog agent running? If the `docker` check is not yet running, rerun the command above until you see the `docker` check running before moving to the next step.
