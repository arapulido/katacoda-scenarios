The Datadog Agent can Autodiscover containers and create check configurations with the Autodiscovery mechanism.

Cluster checks extend this mechanism to monitor noncontainerized workloads, including:

 * Out-of-cluster datastores and endpoints (for example, RDS or CloudSQL).
 * Load-balanced cluster services (for example, Kubernetes services).

In this scenario we will learn how to set up cluster checks for Kubernetes services and Endpoint checks.