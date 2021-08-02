As you have seen, VirtualServices can be used to bind traffic from a Gateway to a particular internal Kubernetes "host", but VirtualServices can be used to create rules to manage internal traffic as well.

We are going to use VirtualServices in combination with [DestinationsRules](https://istio.io/latest/docs/reference/config/networking/destination-rule/) to be able to create a canary deployment for the `advertisements` service. Destination Rules are rules to configure what happens to your network traffic once it has reached the destination defined in a Virtual Service.

We are going to create a second deployment of the `advertisements` container. Open the file called `manifest-files/istio/ads_v2/advertisements_v2.yaml`{{open}} Can you spot the differences between this deployment and the current one running on namespace `ns3`. You can see the differences running this command: `diff -u manifest-files/istio/ecommerce-istio/advertisements.yaml manifest-files/istio/ads_v2/advertisements_v2.yaml`{{execute}}

You can see that we have modified the image, the `DD_VERSION` and now we have also modified the `version` label. Let's apply that manifest: `kubectl apply -f manifest-files/istio/ads_v2/advertisements_v2.yaml`{{execute}}

Open again the Istio Ingress Gateway tab again and refresh it several times. You can see that sometimes you are getting the "Version 1.0" banner and sometimes you get the "Version 2.0" banner. This is not because of Istio, this is because general Service Networking, as we saw on the first scenario. The `advertisements` Service is selecting both pods, so half the time we will get the first one, and half the time we will get the second. We are going to configure Istio to modify those canary rules.

Istio uses labels to be able to define different versions of the same service. To define those different versions we will use a `DestinationRules` object. Open the file called `manifest-files/istio/ads_v2/destinationrule.yaml`{{open}}

In that file we are defining two different subsets of pods for the `advertisements` host: `v1` for pods with the label `version=v1` and `v2` for pods with the label `version=v2`. Let's apply that object: `kubectl apply -f manifest-files/istio/ads_v2/destinationrule.yaml`{{execute}}
