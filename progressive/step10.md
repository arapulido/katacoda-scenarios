Let's start working with Istio. Istio is already deployed for you in the `istio-system` namespace. Have a look to the different deployments in that namespace running the following command: `kubectl get deploy -n istio-system`{{execute}}. You should get an output similar to this one:

```
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
istio-egressgateway    1/1     1            1           37m
istio-ingressgateway   1/1     1            1           37m
istiod                 1/1     1            1           38m
```

We are going to tell Istio to add the Envoy proxy to any pod deployed to namespace `ns3`, by adding it the label `istio-injection`:

`kubectl label namespace ns3 istio-injection=enabled`{{execute}}

Now we are going to deploy the E-commerce application again, this time in this Istio enabled namespace. You can check the differences between our original deployment and this one by running this command: `diff -u manifest-files/ecommerce-v1 manifest-files/istio/ecommerce-istio`{{execute}}. You can see that the main difference (aside from the change in namespace) is that we have changed the type of Service for the `frontend` service to `ClusterIP`, making it unaccessible from outside the cluster:

```
-  type: NodePort
+  type: ClusterIP
```

Let's now deploy the E-commerce application in the `ns3` namespace:

`kubectl apply -f manifest-files/istio/ecommerce-istio -n ns3`{{execute}}

Let's check the pods that are now running in that namespace: `kubectl get pods -n ns3`{{execute}} You should get an output similar to this one (If not all containers are Ready yet, you can execute the previous command several times, until you get all pods up and running):

```
NAME                              READY   STATUS    RESTARTS   AGE
advertisements-849fdbfbb9-8v255   2/2     Running   0          6m45s
discounts-8468fb698c-p952n        2/2     Running   0          6m45s
frontend-575bd7dddb-kqnkw         2/2     Running   0          6m45s
```

As you can see, instead of just one container per pod, we are now getting two containers per pod. Let's check the pods to see what container is running alongside our application: `kubectl get pods -n ns3 -o custom-columns=NAME:.metadata.name,CONTAINERS:".spec.containers[*].image"`{{execute}}. You should get an output similar to this one:

```
NAME                              CONTAINERS
advertisements-849fdbfbb9-8v255   arapulido/ads-service:1.0,docker.io/istio/proxyv2:1.10.2
discounts-8468fb698c-p952n        ddtraining/discounts-fixed:latest,docker.io/istio/proxyv2:1.10.2
frontend-575bd7dddb-kqnkw         arapulido/frontend:1.0,docker.io/istio/proxyv2:1.10.2
```

As you can see, Istio has injected an Envoy proxy container into each of the pods deployed to namespace `ns3`. All comunication between those pods will happen through the Envoy proxy sidecar containers.
