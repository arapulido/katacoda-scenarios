At this point, the application pod-lister is running. But ...

![Screenshot of Kubernetes Dashboard](./assets/apiserver_spam.png)

## Your mission: use Datadog to find the issue

We are looking to graph the top requester, or whatever seems to
be spamming and overloading the apiserver on the `pods` endpoint.

<details>
<summary>Hints</summary>
The [Kubernetes audit logs](https://app.datadoghq.com/logs/analytics?agg_m=&agg_q=%40usr.name&agg_t=count&analyticsOptions=%5B%22bars%22%5D&cols=core_host%2Ccore_service&index=main&live=true&messageDisplay=expanded-md&panel=%22%22&query=source%3Akubernetes.audit+%40usr.name%3A%22system%3Aserviceaccount%3Adefault%3Apod-lister%22&stream_sort=desc) that we added earlier can be helpful to audit
whoever is making calls to the apiserver. You can use facets to filter on a specific resources, URI or requester.<br/><br/>
</details>

If you can't figure out which facets to use to pinpoint the offender, maybe the next hint will help:
<details>
<summary>Hints</summary>
Try to edit the logs query to specifically look at the calls made by the pod lister:

`index:main source:kubernetes.audit @usr.name:"system:serviceaccount:default:pod-lister"`{{copy}}

Then click on "Analytics" in the logs view to display the log query as a metric.
</details>

## Fix the problem

Find a way to fix the issue and implement it! For this one you will have to find
the source code of this application in the `assets/workshop-assets/apps/sample-pod-lister` directory, and look at
a way to fix and replace this spammy call by something else.

NB: If you figure out the solution, no need to bother rebuilding the app - Check out the solution.

<details>
<summary>Fix/Explanation</summary>
You can find in the application source code that it's listing pods with 2
methods: the first one is using a `List` request in a loop every second and the
other one is using a Kubernetes informer (a watch) which is only getting updates
whenever a pod is modified in Kubernetes, rather than requesting the list of all
pods all the time.<br/><br/>

In the source code this behavior is toggled by an env variable `USE_WATCH`, so
try to patch that in your `pod-lister` deployment and watch for the difference
in throughput to the apiserver.<br/><br/>

We included a sample patch as a solution:<br/><br/>
`kubectl patch deployment pod-lister --patch="$(cat assets/workshop-assets/apps/fixes/pod-lister-fix.yaml)"`{{execute}}
</details>
