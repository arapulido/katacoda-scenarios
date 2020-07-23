Steps to reproduce:

* Export your Datadog api key as an env variable: `export DD_API_KEY=<your_api_key>`{{copy}}
* Create the Datadog api secret: `kubectl create secret generic datadog-api --from-literal=token=$DD_API_KEY`{{execute}}
* Apply the following manifests:
 * `kubectl create -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrole.yaml"`{{execute}}
 * `kubectl create -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/serviceaccount.yaml"`{{execute}}
 * `kubectl create -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrolebinding.yaml"`{{execute}}
 * `kubectl apply -f datadog/datadog-agent.yaml`{{execute}}

* Once the Datadog agents are running, execute agent status on the agent running in the `controlplane` node: `k exec $(k get pod -l app=datadog-agent --field-selector spec.nodeName=controlplane -ojsonpath="{.items[0].metadata.name}") agent status`{{execute}}

* Find the section:

```
  API Keys status
  ===============
    API key ending with d2e88: Unable to validate API Key
```

* Execute agent status on the agent running in the `node01` node: `k exec $(k get pod -l app=datadog-agent --field-selector spec.nodeName=node01 -ojsonpath="{.items[0].metadata.name}") agent status`{{execute}}

* Find the section:

```
API Keys status
  ===============
    API key ending with 68306: API Key valid
```
