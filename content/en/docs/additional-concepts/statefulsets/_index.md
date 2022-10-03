---
title: "StatefulSets"
weight: 91
onlyWhenNot: techlab,sbb
---

Stateless applications or applications with a stateful backend can be described as Deployments.
However, sometimes your application has to be stateful.
Examples would be an application that needs a static, non-changing hostname every time it starts or a clustered application with a strict start/stop order of its services (e.g. RabbitMQ).
These features are offered by StatefulSets.

{{% alert title="Note" color="info" %}}
This lab does not depend on other labs.
{{% /alert %}}


## Consistent hostnames

While in normal Deployments a hash-based name of the Pods (also represented as the hostname inside the Pod) is generated, StatefulSets create Pods with preconfigured names.
An example of a RabbitMQ cluster with three instances (Pods) could look like this:

```
rabbitmq-0
rabbitmq-1
rabbitmq-2
```


## Scaling

Scaling is handled differently in StatefulSets.
When scaling up from 3 to 5 replicas in a Deployment, two additional Pods are started at the same time (based on the configuration).
Using a StatefulSet, scaling is done serially:

Let's use our RabbitMQ example again:

1. The StatefulSet is scaled up using: `{{% param cliToolName %}} scale deployment rabbitmq --replicas=5 --namespace <namespace>`
1. `rabbitmq-3` is started
1. As soon as Pod `rabbitmq-3` is in `Ready` state the same procedure starts for `rabbitmq-4`

When scaling down, the order is inverted. The highest-numbered Pod will be stopped first.
As soon as it has finished terminating the now highest-numbered Pod is stopped.
This procedure is repeated as long as the desired number of replicas has not been reached.


## Update procedure

During an update of an application with a StatefulSet the highest-numbered Pod will be the first to be updated and only after a successful start the next Pod follows.

1. Highest-numbered Pod is stopped
1. New Pod (with new image tag) is started
1. If the new Pod successfully starts, the procedure is repeated for the second highest-numbered Pod
1. And so on

If the start of a new Pod fails, the update will be interrupted so that the architecture of your application won't break.


## Dedicated persistent volumes

A very convenient feature is that unlike a Deployment a StatefulSet makes it possible to attach a different, dedicated persistent volume to each of its Pods.
This is done using a so-called _VolumeClaimTemplate_.
This spares you from defining identical Deployments with 1 replica each but different volumes.


## Conclusion

The controllable and predictable behavior can be a perfect match for applications such as RabbitMQ or etcd, as you need unique names for such application clusters.


## {{% task %}} Create a StatefulSet

Create a file named `sts_nginx-cluster.yaml` with the following definition of a StatefulSet:

{{% onlyWhenNot customer %}}
{{< readfile file="/content/en/docs/additional-concepts/statefulsets/sts_nginx-cluster.yaml" code="true" lang="yaml" >}}
{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}
{{< readfile file="/content/en/docs/additional-concepts/statefulsets/sts_nginx-cluster_mobi.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}

Create the StatefulSet:
  
```bash
{{% param cliToolName %}} apply -f sts_nginx-cluster.yaml --namespace <namespace>
```

To watch the pods' progress, open a second console and execute the watch command:

```bash
{{% param cliToolName %}} get pods --selector app=nginx -w --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
Friendly reminder that the `{{% param cliToolName %}} get -w` command will never end unless you terminate it with `CTRL-c`.
{{% /alert %}}


## {{% task %}} Scale the StatefulSet

Scale the StatefulSet up:

```bash
{{% param cliToolName %}} scale statefulset nginx-cluster --replicas=3 --namespace <namespace>
```

You can again watch the pods' progress like you did in the first task.


## {{% task %}} Update the StatefulSet

In order to update the image tag in use in a StatefulSet, you can use the `{{% param cliToolName %}} set image` command.
Set the StatefulSet's image tag to `latest`:

{{% onlyWhenNot mobi %}}
```bash
{{% param cliToolName %}} set image statefulset nginx-cluster nginx={{% param "images.nginxinc-nginx-unprivileged" %}} --namespace <namespace>
```
{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}
```bash
kubectl set image statefulset nginx-cluster nginx={{% param "images.nginx" %}} --namespace <namespace>
```
{{% /onlyWhen %}}


## {{% task %}} Rollback

Imagine you just realized that switching to the `latest` image tag was an awful idea (because it is generally not advisable).
Rollback the change:

```bash
{{% param cliToolName %}} rollout undo statefulset nginx-cluster --namespace <namespace>
```


## {{% task %}} Cleanup

As with every other {{% param distroName %}} resource you can delete the StatefulSet with:

{{% alert title="Warning" color="warning" %}}
To avoid issues on your personal progress dashboard, we would advise not to delete the StatefulSet from this lab
{{% /alert %}}

```
{{% param cliToolName %}} delete statefulset nginx-cluster --namespace <namespace>
```

Further information can be found in the [Kubernetes' StatefulSet documentation](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) or this [published article](https://opensource.com/article/17/2/stateful-applications).
