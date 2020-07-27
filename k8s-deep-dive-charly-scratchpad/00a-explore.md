Access the Kubernetes API using the command line client, `kubectl`. The environment is configured to connect to your personal Kubernetes cluster.

You may explore the functionality provided by `kubectl` using `kubectl --help`{{execute}}.

Start by verifying that your cluster is running the expected version of Kubernetes, `v1.16`. `kubectl version`{{execute}} prints the client and server versions.

Make sure that all the nodes in your cluster are in `Ready` state. If your nodes are `NotReady`, wait a few seconds and try again until they become `Ready`. `kubectl get nodes`{{execute}} prints a list of the nodes in your cluster.

Then, take a look at the pods running the control plane:
`kubectl get pods -n kube-system`{{execute}}