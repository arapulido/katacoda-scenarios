1. Navigate to the Datadog Integrations page and install the etcd integration.
1. Install the Helm chart using the helm install command: `helm install datadogagent --set datadog.apiKey=$DD_API_KEY --set datadog.appKey=$DD_APP_KEY -f values.yaml stable/datadog`{{execute}}.
1. Now run the Datadog agent status command to verify that etcd metrics are being collected. As you can see there is a problem. By the way, here is a way to run that exec command without having to figure out the name of the agent pod, since there is only one agent running. `k get pod -l app=datadogagent -o jsonpath="{.items[0].metadata.name}"`{{execute}} will show us the current name of that pod, so `k exec $(k get pod -l app=datadogagent -o jsonpath="{.items[0].metadata.name}") agent status`{{execute}} will run agent status with that pod name automatically.  If you get `error: unable to upgrade connection: container not found ("agent")`, then the pod isn't ready yet. Run `k get pods`{{execute}} to see their current status.
1. That was a pretty complicated command to get the agent status to come up. Thankfully there is a plugin system for kubectl as well, called krew. The match-name plugin is already installed, so you can also try `k match-name datadog`{{execute}} to get the name of the datadog agent pod, but that will get the first in the list that start with **datadog**. Using a full regex gets what we need every time: `k exec $(k match-name datadogagent-[a-z0-9]{5}) agent status`{{execute}}.
1. As you can see there is an error with the etcd integration. Let's first look at how Datadog is configured to run. `k exec $(k match-name datadogagent-[a-z0-9]{5}) agent configcheck`{{execute}}. Scroll up to etcd and look at the configuration.
1. Now let's take a look at the etcd pod to see how it is configured. `k describe pod -n kube-system etcd-master`{{execute}}. You can see the metrics url as well as a number of other command line options used to start etcd. So we can start there.
1. The `etcd` check was automatically run thanks to [Datadog's Autodiscovery feature](https://docs.datadoghq.com/agent/kubernetes/integrations/?tab=kubernetes), but it seems that the default configuration didn't work. The `etcd` command shows a number of certs being used. The reason our metrics call is failing is that we aren't making that secure connection. In order to make the certs available to the Datadog agent, we need to create a volume, mount it, and then add those to the configuration for the etcd integration. First add the volumes. At around line 830, update your volume declarations:

        volumes:
          - hostPath:
              path: /etc/kubernetes/pki/etcd
            name: etcd-keys

1. Just below that in the volumeMounts update as shown: 

        volumeMounts:
        - mountPath: /keys
          name: etcd-keys
          readOnly: true
1. Now upgrade the helm chart: `helm upgrade datadogagent --set datadog.apiKey=$DD_API_KEY --set datadog.appKey=$DD_APP_KEY -f values.yaml stable/datadog`{{execute}}.
1. The next thing that we will need to do is to change the check configuration. How do we do that if the check was automatically run with Autodiscovery? Datadog's Autodiscovery feature allows to change the check configuration adding annotations to the pod that is the target of the check, in our case, the `etcd-master` pod. You can learn more about adding the right annotations to your pods in our [official documentation](https://docs.datadoghq.com/agent/kubernetes/integrations/?tab=kubernetes#configuration).
1. But, where is the `etcd-master` pod definition? The ETCD pod is defined as a [static pod in Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/#configuration-files). A folder in the file system can be watched by the Kubelet and start the pods that are described in that folder. In our environment this folder is `/etc/kubernetes/manifests`. Check the contents of that folder: `ls /etc/kubernetes/manifests`{{execute}.
1. Our pod definition is on the `etcd.yaml` file. Let's copy that file to our home folder so we can easily edit it: `cp /etc/kubernetes/manifests/etcd.yaml $HOME`{{execute}}
1. Open the `etcd.yaml` file in the editor by clicking the IDE tab to the right and choosing the file and add the following content under line 3:

  annotations:
    ad.datadoghq.com/etcd.check_names: '["etcd"]'
    ad.datadoghq.com/etcd.init_configs: '[{}]'
    ad.datadoghq.com/etcd.instances: |
      [
        {
          "prometheus_url": "https://%%host%%:2379/metrics",
          "ssl_verify": "false",
          "use_preview": "true",
          "ssl_ca_cert": "/keys/ca.crt",
          "ssl_cert": "/keys/peer.crt",
          "ssl_private_key": "/keys/peer.key"
        }
      ]
1. Let's copy back the file to the static pods folder: `cp etcd.yaml /etc/kubernetes/manifests/`{{execute}}
1. Finally, let's kill the ETCD pod, so it gets restarted by the Kubelet automatically based on our new configuration: `k delete po -n kube-system etcd-master`{{execute}}
1. Now check the agent status again and you should see that etcd data is being collected and there are no errors.