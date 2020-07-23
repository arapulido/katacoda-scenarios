Our current Datadog agent configuration doesn't have logs collection enabled. We will enable log collection using this section of the Helm `values.yaml` file:

```
  logs:
    ## @param enabled - boolean - optional - default: false
    ## Enables this to activate Datadog Agent log collection.
    ## ref: https://docs.datadoghq.com/agent/basic_agent_usage/kubernetes/#log-collection-setup
    #
    enabled: true

    ## @param containerCollectAll - boolean - optional - default: false
    ## Enable this to allow log collection for all containers.
    ## ref: https://docs.datadoghq.com/agent/basic_agent_usage/kubernetes/#log-collection-setup
    #
    containerCollectAll: true
```

You can read more on our [official documentation](https://docs.datadoghq.com/agent/kubernetes/log/?tab=helm).

You can view this new section opening this file: `assets/04-datadog-logs/values.yaml`{{open}}. Navigate to line 208 to check the section.

* Apply the new `values.yaml`: <br/>
`helm upgrade datadogagent --set datadog.apiKey=$DD_API_KEY -f assets/08-datadog-logs/values.yaml stable/datadog`{{execute}}

