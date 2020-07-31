## Welcome! 

This workshop is on troubleshooting outages in Kubernetes.

Wait a few minutes until your environment is setup. Once it is setup, you will see the following message in your terminal:`OK, the training environment is installed and ready to go.`

This is your development environment. A 2 nodes Kubernetes cluster was created and configured for you. You can access the Kubernetes API using the command line client, `kubectl`. 

You may explore the functionality provided by `kubectl` using `kubectl --help`{{execute}}.

* Start by verifying that your cluster is running the expected version of Kubernetes, `v1.16`. `kubectl version`{{execute}} prints the client and server versions.

* Make sure that all the nodes in your cluster are in `Ready` state. If your nodes are `NotReady`, wait a few seconds and try again until they become `Ready`. `kubectl get nodes`{{execute}} prints a list of the nodes in your cluster.

* Then, take a look at the pods running the control plane:
`kubectl get pods -n kube-system`{{execute}}
