
Crazy that someone would leave a sleep in the code!

![ads image fix](./assets/ads_image_fixed.png)

Let's apply the patch and make sure it works.
`kubectl patch deploy advertisements --patch="$(cat assets/workshop-assets/apps/fixes/advertisements.yaml)"`{{execute}}.


Once this is running, see if the app is faster and then confirm with the traces that the time spent in the advertisements micro service is much better.

[Insert trace image]

Well, sounds like we are all good on the customers side ?