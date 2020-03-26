## Datadog Cluster Agent

We will deploy now the Datadog Cluster Agent that will work as External Metrics Server for our scaling events.

First, we will create a token that will be used to secure the communication between the cluster agent and the host agents. Create the secret with the token by running the following command: `kubectl create secret generic datadog-auth-token --from-literal token="<ThirtyX2XcharactersXlongXtoken>"`{{execute}}

Also, in order to be able to use the Cluster Agent as External Metrics Server, we will need to generate a Datadog Application Key (which is different from your API key). To do so, open the Datadog application and navigate to [Integrations -> APIs](https://app.datadoghq.com/account/settings#api). Click on Applications Keys and generate a new application key:

TODO: Add screenshot

Once generated, copy the value and create a new secret with it:

```
$ kubectl create secret generic datadog-app-key --from-literal app-key=<YOUR_NEWLY_GENERATED_DATADOG_APP_KEY>
```

Check that the secret has been correctly created by running the following command: `kubectl get secret datadog-app-key`{{execute}} You should get an output similar to the following:

```
NAME             TYPE      DATA      AGE
datadog-app-key   Opaque    1         8s
```

Before deploying the datadog cluster agent, we will delete the current Datadog agent DaemonSet, to avoid conflicts: `kubectl delete daemonset datadog-agent`{{execute}}

We will now deploy the Datadog Cluster Agent. Open the file called `datadog/datadog-cluster-agent.yaml` in the editor and try to understand the different options that are set there. Can you spot which option enables the External Metrics Server for the HPA controller? Let's deploy it by executing `kubectl apply -f datadog/datadog-cluster-agent.yaml`{{execute}}