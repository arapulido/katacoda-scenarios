## Audit Logs & RBAC: Hands-on intro

Whenever an API request is made to the Kubernetes apiserver, we can emit an
audit log line describing the request.

In this environment, the apiserver is configured to send the audit logs to
`/var/log/kubernetes/apiserver/audit.log`, go ahead and have a look at one
request log.
`tail -n1 /var/log/kubernetes/apiserver/audit.log | jq .`{{execute}}

<details>
<summary>Additional Information</summary>
The apiserver is running on the master node as a [_static
pod_](https://kubernetes.io/docs/tasks/administer-cluster/static-pod/) so this
application can be configured via a local file manifest located in:
`/etc/kubernetes/manifests/kube-apiserver.yaml`. <br/> <br/>

Find the flags we pass to the apiserver binary to configure audit logs:
  `--audit-log-path` and `--audit-policy-file`. <br/> <br/>

You can also read [the Kubernetes reference
  documentation](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/)
on auditing. <br/> <br/>

*Attention: as static pods manifests are automatically reloaded, if you
introduce a breaking in change in the apiserver manifest, it might break your
Kubernetes environment. If `kubectl` commands are failing, try to fix the
manifest, reach out if you are blocked.*
</details>
