We just presented the ecommerce application with the slides

If you have not already, open the [Kubernetes Pod Overview dashboard](https://app.datadoghq.com/screen/integration/30322)


Here they should use the kubernetes pod dashboard to identify that one pod is in crashloop in a  namespace we did not disclose (when presenting the app we need to tell them about the gor pod)

We don't tell them where it is, we just mention that they should use the dahsboard to see where it is
Then they describe it to see what is wrong
Then the image is not pulling

`kubectl patch deploy load-balancer-traffic -n external --patch "$(cat assets/workshop-assets/apps/fixes/gor_pod_image.yaml)"`{{execute}}

apply patch 2

They path the command
`kubectl patch deploy load-balancer-traffic -n external --type json -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'`{{execute}}


Then we tell them to look at the traces coming in.




