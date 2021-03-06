As we have explained, Vertical Scaling in Kubernetes refers to the amount of resources (CPU and memory) assigned to a particular Pod through their resources definition.

Open the `k8s-manifests/ecommerce-app/frontend.yaml`{{open}} file in the editor. This file defines the Deployment and Service for the Frontend service (our monolith application) of our ecommerce application. Navigate to the `resources` section of our Pod definition. You will see something like:

```
resources:
  requests:
    cpu: 100m
    memory: 100Mi
```

We are making a contract with the Kubernetes Scheduler to ensure that the Node our Frontend service is running on, has always 10% CPU core and 100Mi memory reserved for this Pod. But, are those enough resources to run this Pod? Let's create a VPA to find out.

First, we need to deploy the Vertical Pod Autoscaler (VPA), which is an optional component of a Kubernetes cluster, and not part of a default installation.

Open the `k8s-manifests/vertical-pod-autoscaler` folder in the editor and check the different manifests. We will only deploy the Recommender deployment, so our VPA will only work in "Recommend" mode. Apply the manifests to create the VPA deployment: `kubectl apply -f k8s-manifests/vertical-pod-autoscaler`{{execute}}

Once we have the VPA deployment up and running, we want to create a VPA object to track our Frontend deployment, so we get recommendations on the amount of CPU requests that we should apply to our Deployment.

We are going to create a new file called `frontend-vpa.yaml` (file creation happens automatically by clicking below on "Copy to Editor"):

<pre class="file" data-filename="frontend-vpa.yaml" data-target="replace">
apiVersion: autoscaling.k8s.io/v1beta2
kind: VerticalPodAutoscaler
metadata:
  name: frontend-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: frontend
  updatePolicy:
    updateMode: "Off"
</pre>

Create the VPA object by applying the just created manifest: `kubectl apply -f frontend-vpa.yaml`{{execute}} You can check that the VPA object was created correctly by running the following command: `kubectl get vpa`{{execute}} You should get output similar to:

```
NAME           AGE
frontend-vpa   8s
```

While the VPA gathers the needed data to make the recommendation, let's spend sometime understanding the VPA object.

```
targetRef:
  apiVersion: "apps/v1"
  kind: Deployment
  name: frontend
```

This first section of the VPA manifest describes the objects that are the target for the VPA recommendations. In our case, the pods for our `frontend` deployment will be the target of the recommendations.

```
updatePolicy:
  updateMode: "Off"
```

This section specifies the mode in which VPA is operating. In our case, "Off" indicates that the VPA won't automatically change the resource requirements of the pods. The recommendations are calculated and can be inspected in the VPA object. You can read about the different modes in which the VPA can run in [the official VPA documentation](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#quick-start).

Let's check the CPU and memory requests recommendations that the VPA provides for our deployment by examining our VPA object: `kubectl describe vpa frontend-vpa`{{execute}}

What recommendations is the VPA giving? Tip: check the part of the output for the "Target" recommendation.

To finish, let's remove the VPA object before moving to the next section by executing: `kubectl delete -f frontend-vpa.yaml`{{execute}}
