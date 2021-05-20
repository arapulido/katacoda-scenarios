GitOps is a series of good practices that recommends to store all cluster configuration in Git and use a git repository as the source of truth, having peer reviews for any changes prior to pushing them to production, and having automation to reconciliate what it is stored in the repository to production.

GitOps can be considered, in a way, an evolution of concepts like infrastructure and configuration as code. But what about Observability? What if we could store the signals we care about in our application next to the application code and the cluster configuration?

DatadogMonitor allows to define Datadog monitors (alerts) as Kubernetes objects, allowing to store them in Git with the rest of your application configuration.

DatadogMonitor requires to use the Datadog Operator. We recommend you to follow [this other scenario first to learn the basics of using the Datadog Operator](https://labs.datadoghq.com/snippets/understanding-the-datadog-operator).
