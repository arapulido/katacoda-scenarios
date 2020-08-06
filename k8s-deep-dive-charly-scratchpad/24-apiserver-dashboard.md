Good dashboards can be extremely valuable to monitor the health and performance of our applications and infrastructure. 

Can you make a great Kubernetes dashboard that everyone would like to use? We have a challenge for you!

## Goal: Create the best Kubernetes API Server dashboard (and you may be featured by Datadog)

The API Server is the gateway to the Kubernetes cluster and acts as a central hub for all users, components, and automation processes. Alongside gRPC communication, the API Server also implements a RESTful API over HTTP and is responsible for storing API objects into etcd. The API Server also listens to the Kubernetes API and implements a number of verbs:

* GET: retrieves specific information about a resource (e.g., data from a specific pod)
* LIST: retrieves an inventory of Kubernetes objects (e.g., a list of all pods in a given namespace)
* POST: creates a new resource based on a JSON object sent with the request
* DELETE: removes a resource from the cluster (e.g., deleting a pod)

### Key metrics to monitor
Acting as the gateway between cluster components and pods, the API Server is especially important to monitor. Datadog collects metrics that allow you to quantify the server’s workload and its supporting resources, such as the number of requests (broken down by verb), goroutines, and threads. You can also monitor the depth of the registration queue, which tracks queued requests from the Controller or Scheduler and can reveal if the API Server is falling behind in its work. In addition to tracking the total number of server requests, the new integration enables you to monitor for an increase in the number of dropped requests, which is a strong signal of resource saturation.

### Tips:

- Get to know which API Server metrics are collected by Datadog. You can find the full list in [our docs](https://docs.datadoghq.com/integrations/kube_apiserver_metrics/#data-collected)
- Use Datadog's [Metrics Summary page](https://app.datadoghq.com/metric/summary) and [Metrics Explorer page](https://app.datadoghq.com/metric/explorer) to learn more about each metric, such as which tags you could use in graphs and widgets.
- Take a look at the existing Datadog dashboards for Kubernetes Control Plane: 
    - [Kubernetes Controller Manager - Overview](https://app.datadoghq.com/screen/integration/30271/kubernetes-controller-manager---overview)
    - [Kubernetes Scheduler Manager - Overview](https://app.datadoghq.com/screen/integration/30270/kubernetes-scheduler---overview)
    - [Etcd Overview](https://app.datadoghq.com/screen/integration/30289/etcd-overview)

Now, with all this knowledge, let's have some fun:
1. Go to Datadog, and choose [Dashboards -> New Dashboard](https://app.datadoghq.com/dashboard/lists#).
1. Choose "New Screenboard"
1. Build a dashboard and name it "Kubernetes API Server - Overview"
1. Once you are done, share your dashboards with us if you'd like (a link will be provided in the chat window)
1. If your dashboard wins, ... *TBD*

Good luck!
