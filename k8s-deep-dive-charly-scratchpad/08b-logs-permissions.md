Now that you have learned about the audit logs and rbac, let's see what they look like in your cluster.

First of all, in order to generate some interesting logs, we have built a small app that will query the APIServer to give us usefull insight.
create the audit-log-generator deployment:

`kubectl apply -f assets/workshop-assets/apps/manifests/pod-lister.yaml`

As the pod is deployed, you will notice that it is not Running correctly.
Try to use the logs in Datadog to spot the issue.

<details>
<summary>Hints</summary>
# TODO update url
The [Kubernetes audit logs](https://app.datadoghq.com/logs?cols=core_host%2Ccore_service&event&index=main&live=true&query=source%3Akubernetes.audit&stream_sort=desc) that we added earlier can be helpful to audit
whoever is making calls to the apiserver. You can use facets to filter on a
specific resources, URI or requester.<br/><br/>

In this case we are looking for `403` HTTP response status codes.
</details>

Find a way to fix the issue and implement it!

<details>
<summary>Fix/Explanation</summary>
The `pod-lister` application is making calls to the apiserver to ... list the
pods. However its service account is missing permissions to perform the `list
pods` API call.<br/><br/>

If you run `kubectl get clusterroles pod-lister -oyaml`{{copy}} you will see what the
service account permissions are.<br/><br/>

In this case you will need to add permissions for the `list` verb to the `/pods`
resource.<br/><br/>

We included a sample patch as a solution:<br/><br/>
`kubectl patch clusterroles pod-lister --patch="$(cat assets/workshop-assets/apps/fixes/rbac-fix.yaml)"`{{copy}}
</details>