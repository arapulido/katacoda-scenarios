Now that we are gathering etcd metrics, let's take a look at which metrics we need to look at. Of course, the metrics that are most important to you depend on your business objectives, but the metrics we look at in this lab are a good start.

1. Let's start with creating a new Timeboard and name it `Training ETCD`. If you aren't familiar with creating dashboards, review the **Introduction to Datadog** course here on the Learning Center. 
1. Add a new group widget to the dashboard and call it **Proposals**. 
1. Add a Timeseries widget to the group and add the metric `etcd.server.proposals.commited.total`. Repeat for `etcd.server.proposals.applied.total`.
1. These two graphs probably look the same. Maybe a more interesting graph would show the commited count and then how many were applied but not commited, which is hopefully zero. Edit the commited graph and then click the **Advanced...** link to the right of the metric. Click the **Add Query** button and add the applied metric.
1. Check the checkbox next to the **b** to the left of the metrics, then add the formula `b-a`. Click the **as...** link to the right of that formula and enter `Applied but not Commited`. Click the **Save** button. 
1. Think of a way to add the `etcd.server.proposals.failed.total` and `etcd.server.proposals.pending` metrics.
1. Now let's look at disk performance. Do you remember the metrics mentioned in the video? They were `etcd.disk.wal.fsync.duration.seconds` and `etcd.disk.backend.commit.duration.seconds`. Think about the right way to display that data on the dashboard. *(There are no right and wrong approaches here.)*
1. Database size has a finite maximum and you need to make sure you are always below that level. This would be a great place to add the forecasting formula. Add a Timeseries for `etcd.debugging.mvcc.db.total.size.in_bytes` and then choose **Forecast** under **Algorithms** when you click the plus sign at the end of the row. Try out the different options to see what works here. Of course, you don't have much data yet, so it's hard to come up with an accurate forecast, but hopefully you can imagine what is possible. You might want to also add a Marker for when it gets to a warning level. 
1. The last group of metrics to pay attention to are around network performance. The metrics that were discussed in the video are:
   
   * etcd.grpc.server.msg.received.total
   * etcd.grpc.server.msg.sent.total
   * etcd.network.client.grpc.received.bytes.total
   * etcd.network.client.grpc.sent.bytes.total

   Try out the different options for displaying these metrics.

Obviously there are many more metrics you can work with here but this should give you a good starting place. 