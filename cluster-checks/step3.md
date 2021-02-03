Now that we have our Datadog agent up and running we will create a NGINX Kubernetes deployment with 3 pods.

Open the file called `cluster-checks-files/nginx-deploy.yaml`{{open}} and check that we are going to create a regular 3 replicas NGINX deployment using the `bitnami/nginx` image.

Create the deployment applying that YAML file:

`kubectl apply -f cluster-checks-files/nginx-deploy.yaml`{{execute}}

Let's check the workloads that have been deployed:

`kubectl get deployment nginx`{{execute}}

If we run again the agent status commend, we see that the NGINX check is not running:

`kubectl exec -ti $(kubectl get pods -l app=datadog -o custom-columns=:metadata.name) -- agent status`{{execute}}

We are going to annotate the deployment to enable the [NGINX integration](https://docs.datadoghq.com/integrations/nginx/?tab=host). To learn how to annotate Kubernetes deployments to enable integrations, you can refer to [the official documentation](https://docs.datadoghq.com/agent/kubernetes/integrations/?tab=kubernetes).

We have prepared a file with the right annotations. Open the file `cluster-checks-files/nginx-deploy-annotations.yaml`{{open}} and check the annotations to enable the NGINX check.

You can check the difference between both deployments running this command: `diff cluster-checks-files/nginx-deployment.yaml cluster-checks-files/nginx-deploy-annotations.yaml`{{execute}}

Lets apply those changes:


