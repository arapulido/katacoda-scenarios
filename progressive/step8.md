Our Ecommerce logo is the Spree standard one:

![Screenshot of the Spree logo](./assets/spree_logo.png)

We are going to apply a second deployment for the `frontend` service, that uses a different docker image label, that changes the default logo, so we can distinguish them easily.

Open the file called `manifest-files/ingress/ecommerce-v2/frontend.yaml`{{open}} and try to spot the differences with the original one. You can spot the differences running the following `diff` command: `diff -u manifest-files/ecommerce-v1/frontend.yaml  manifest-files/ingress/ecommerce-v2/frontend.yaml`{{execute}}

As you can see we have modified the image tag and the value for the `DD_VERSION` environment variable, to make sure we can track correctly both versions in Datadog. Also, you can see that this second deployment will change the labels slightly, because we will also create a second different Kubernetes service for this one.

Open the file called `manifest-files/ingress/ecommerce-v2/frontend-svc.yaml`{{open}} and try to spot the differences with the first frontend service. You can spot the differences running the following `diff` command: `diff -u manifest-files/ecommerce-v1/frontend-svc.yaml  manifest-files/ingress/ecommerce-v2/frontend-svc.yaml`{{execute}}

As you can see, the only difference is that this second service selects the pods with the label `service:frontendv2`, which is the label we had changed for this second deployment. We have also removed the NodePort for this second service, as we will be accessing it through Ingress.

```
   selector:
-    service: frontend
+    service: frontendv2
```

Let's apply the second deployment and the second service: `kubectl apply -f manifest-files/ingress/ecommerce-v2/frontend.yaml && kubectl apply -f manifest-files/ingress/ecommerce-v2/frontend-svc.yaml`{{execute}}

We have now two different deployments for `frontend` with a different set of labels, running different docker images: `kubectl get deployments -n ns1  --show-labels | grep frontend`{{execute}} You may need to rerun this command several times until you see the `frontendv2` deployment ready.

```
frontend         1/1     1            1           21m   app=ecommerce,service=frontend
frontendv2       1/1     1            1           27s   app=ecommerce,service=frontendv2
```

Click again on the "Ingress Service" tab and refresh several times the page. As you can see, you still only see version 1.0 for the `frontend` service. The reason is that we haven't added an Ingress object for the second service. Let's do that now.

We are going to create a second Ingress object for our canary service. Open the file called `manifest-files/ingress/ecommerce-v2/ingressv2.yaml`{{open}} and try to spot the differences with the first frontend Ingress object. You can spot the differences running the following `diff` command: `diff -u manifest-files/ingress/ingressv1.yaml  manifest-files/ingress/ecommerce-v2/ingressv2.yaml`{{execute}}

You can see that apart from the  NGINX canary annotations, this Ingress object will point to the second `frontendv2` service, instead of the first one:

```
-  name: frontend-ingress
+  name: frontend-ingress-v2 
   namespace: ns1
   annotations:
     nginx.ingress.kubernetes.io/rewrite-target: /
+    nginx.ingress.kubernetes.io/canary: "true"
+    nginx.ingress.kubernetes.io/canary-weight: "50"

[...]
         pathType: Prefix
         backend:
           service:
-            name: frontend
+            name: frontendv2
```

Let's apply that new Ingress object: `kubectl apply -f manifest-files/ingress/ecommerce-v2/ingressv2.yaml`{{execute}}

Refresh several times again the page for the `Ingress Service`. You will see that sometimes you are getting the old logo and sometimes you are getting the new one:

![Screenshot of new logo](./assets/storedog_logo.png)

Let's navigate to the [Frontend Service Overview page](https://app.datadoghq.com/apm/service/store-frontend/) in Datadog. Datadog is now tracking two different versions of the `store-frontend` service:

![Screenshot of frontend service overview page with two versions](./assets/frontend_service_page_v2.png)

Click on the `2.0` row under "Deployments" and you will get a comparison between the two versions:

![Screenshot of frontend service comparison between version 1.0 and version 2.0](./assets/frontend_service_comparison.png)

Are we getting new errors? Is the latency of the two versions similar? Are we happy with progressively moving this release forward or shall we rollback?

If you wait long enough, you will see that this second version has a slightly higher error rate and it might be safer to rollback. You can get also this information in the `frontend` service overview page:

![Screenshot of frontend service comparison for error rates](./assets/frontend_error_rate.png)

**IMPORTANT**: Before continuing, let's revert the second version of the `frontend` service to make sure the rest of the labs work correctly: `kubectl delete -f manifest-files/ingress/ecommerce-v2/`{{execute}}
