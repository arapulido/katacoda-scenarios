Now that you have learned about the audit logs and rbac, let's see what they look like in your cluster.

First of all, in order to generate some interesting logs, we have built a small app that will query the APIServer to give us useful insight.
create the audit-log-generator deployment:

`kubectl apply -f assets/workshop-assets/apps/manifests/pod-lister.yaml`{{execute}}

As the pod is deployed, you will notice that it is not Running correctly.
Try to use the logs in Datadog to spot the issue.

<details>
<summary>Hints</summary>
The [Kubernetes audit logs](https://app.datadoghq.com/logs?cols=core_host%2Ccore_service&event&index=main&live=true&query=source%3Akubernetes.audit&stream_sort=desc) that we added earlier can be helpful to audit
whoever is making calls to the apiserver. You can use facets to filter on a
specific resources, URI or requester.<br/><br/>

In this case we are looking for `403` HTTP response status codes.
</details>

If you are digging through the audit logs, and can't figure out how to identify the ones that we are specifically interested in, maybe this hint will help:

<details>
<summary>Hints</summary>
Try to use the following query in the log search: 

`index:main source:kubernetes.audit @http.status_code:403`
</details>


Find a way to fix the issue and implement it!

<details>
<summary>Fix/Explanation</summary>
The `pod-lister` application is making calls to the apiserver to ... list the
pods. However its service account is missing permissions to perform the `list
pods` API call.<br/><br/>

If you run `kubectl get clusterroles pod-lister -oyaml`{{execute}} you will see what the
service account permissions are.<br/><br/>

In this case you will need to add permissions for the `list` verb to the `/pods`
resource.<br/><br/>

We included a sample patch as a solution. Run the following to use it:<br/><br/>
`kubectl patch clusterroles pod-lister --patch="$(cat assets/workshop-assets/apps/fixes/rbac-fix.yaml)"`{{execute}}

Check if `pod-lister` Pod is still in now running:<br/><br/>
`kubectl get pods`{{execute}}

If it is still in a CrashloopBackoff State, such as:
```
pod-lister-b754c75db-rsz9s                       0/1     CrashLoopBackOff   5          4m33s
```

Feel free to delete it by running the following:<br/><br/>
`kubectl delete po $(kubectl get pods -lapp=pod-lister -o custom-columns=:metadata.name)`{{execute}}

The deployment controller will create a new pod using the new RBAC that will be in a running state.

`kubectl delete po $(kubectl get pods -lapp=pod-lister -o custom-columns=:metadata.name)`{{execute}}

</details>

