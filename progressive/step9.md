We are going to deploy version 2.0 for the `advertisements` service, but this time we are going to using an Ingress object to move some of the traffic to this second version.

As this is not the service that the Ingress object calls, but rather a service that the `frontend` service calls, we are going to duplicate our application in a second namespace.

Open the folder called `manifest-files/ingress_ns/ecommerce-v2`{{open}} and browse around. You can see the differences between the manifests in this folder and the one in `ecommerce-v1` by running this command: `diff -u manifest-files/ecommerce-v1 manifest-files/ingress_ns/ecommerce-v2`{{execute}}

As you can see, the only differences are that: we are creating the services and deployments in the `ns2` namespace; we have changed the NodePort for the `frontend` service to avoid clashes, and we are using the `2.0` label for the `advertisements` docker image (similar to what we did in the labs about Service Networking).

Let's apply the complete folder: `kubectl apply -f manifest-files/ingress_ns/ecommerce-v2/`{{execute}}

We have now our application replicated in namespace `ns2`. Let's check it: `kubectl get deploy -n ns2 && kubectl get svc -n ns2`{{execute}} You should get an output similar to this one:

```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
advertisements   1/1     1            1           75m
discounts        1/1     1            1           75m
frontend         1/1     1            1           75m
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
advertisements   ClusterIP   10.104.77.49    <none>        5002/TCP       75m
discounts        ClusterIP   10.102.145.2    <none>        5001/TCP       75m
frontend         NodePort    10.108.72.123   <none>        80:30002/TCP   74m
```

Click again on the "Service Ingress" tab and refresh several times the page. As you can see, you still only see version 1.0 for the `advertisements` service. The reason is that we haven't added an Ingress object for the `frontend` service in the `ns2` namespace. Let's do that now.

We are going to create a second Ingress object for our canary service. Open the file called `manifest-files/ingress_ns/ingressv2.yaml`{{open}} and try to spot the differences with the first frontend Ingress object. You can spot the differences running the following `diff` command: `diff -u manifest-files/ingress/ingressv1.yaml  manifest-files/ingress_ns/ingressv2.yaml`{{execute}}

Our Ecommerce logo is the Spree standard one:

![Screenshot of the Spree logo](./assets/spree_logo.png)

We are going to apply a second deployment for the `frontend` service, that uses a different docker image label, that changes the default logo, so we can distinguish them easily.

Open the file called `manifest-files/ingress/ecommerce-v2/frontend.yaml`{{open}} and try to spot the differences with the original one. You can spot the differences running the following `diff` command: `diff -u manifest-files/ecommerce-v1/frontend.yaml  manifest-files/ingress/ecommerce-v2/frontend.yaml`{{execute}}

As you can see we have modified the image tag and the value for the `DD_VERSION` environment variable, to make sure we can track correctly both versions in Datadog. Also, you can see that this second deployment will change the labels slightly, because we will also create a second different Kubernetes service for this one.

Open the file called `manifest-files/ingress/ecommerce-v2/frontend-svc.yaml`{{open}} and try to spot the differences with the first frontend service. You can spot the differences running the following `diff` command: `diff -u manifest-files/ecommerce-v1/frontend-svc.yaml  manifest-files/ingress/ecommerce-v2/frontend-svc.yaml`{{execute}}

As you can see, the only difference is that this second service selects the pods with the label `service:frontendv2`, which is the label we had changed for this second deployment.

Let's apply the second deployment and the second service: `kubectl apply -f manifest-files/ingress/ecommerce-v2/frontend.yaml && kubectl apply -f manifest-files/ingress/ecommerce-v2/frontend-svc.yaml`{{execute}}

We have now two different deployments for `frontend` with a different set of labels, running different docker images: `kubectl get deployments -n ns1  --show-labels | grep frontend`{{execute}}.

Click again on the "Service Ingress" tab and refresh several times the page. As you can see, you still only see version 1.0 for the `frontend` service. The reason is that we haven't added an Ingress object for the second service. Let's do that now.

We are going to create a second Ingress object for our canary service. Open the file called `manifest-files/ingress/ecommerce-v2/ingressv2.yaml`{{open}} and try to spot the differences with the first frontend Ingress object. You can spot the differences running the following `diff` command: `diff -u manifest-files/ecommerce-v1/ingress/ingressv1.yaml  manifest-files/ingress/ecommerce-v2/ingressv2.yaml`{{execute}}

You can see that we have added two NGINX annotations:

```
+    nginx.ingress.kubernetes.io/canary: "true"
+    nginx.ingress.kubernetes.io/canary-weight: "50"
```

With those two annonations we are telling the NGINX Ingress controller that this second Ingress is a canary of the first one (it has the same `path`), and to direct 50% of the traffic to this canary service.

Let's apply that new Ingress object: `kubectl apply -f manifest-files/ingress/ecommerce-v2/ingressv2.yaml`{{execute}}

Refresh several times again the page for the `Ingress Service`. You will see that sometimes you are getting the Version 1.0 banner and sometimes you are getting the Version 2.0 one:

![Screenshot of Ecommerce app with ads version 2.0](./assets/ads_v2.png)

**IMPORTANT**: Before continuing, let's revert the second version of the application to make sure the rest of the labs work correctly: `kubectl delete ns ns2`{{execute}}