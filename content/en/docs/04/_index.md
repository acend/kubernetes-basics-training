---
title: "4. Deploy a container image"
weight: 4
sectionnumber: 4
---

In this lab, we are going to deploy our first pre-built container image and look at the concepts Pod, Service, and Deployment.


## Task {{% param sectionnumber %}}.1: Start and stop a single Pod

After we've familiarized ourselves with the platform, we are going to have a look at deploying a pre-built container image from Docker Hub or any other public container registry.

First, we are going to directly start a new Pod:
{{< onlyWhenNot mobi >}}

```bash
{{% param cliToolName %}} run awesome-app --image=quay.io/acend/example-web-go:latest --restart=Never --namespace <namespace>
```

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

```bash
kubectl run awesome-app --image=docker-registry.mobicorp.ch/puzzle/k8s/kurs/example-web-go --restart=Never --namespace <namespace>
```

{{< /onlyWhen >}}

Use `{{% param cliToolName %}} get pods --namespace <namespace>` in order to show the running Pod:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

Which gives you an output similar to this:

```
NAME          READY   STATUS    RESTARTS   AGE
awesome-app   1/1     Running   0          1m24s
```

{{% onlyWhen rancher %}}
Have a look at your awesome-app Pod inside the Rancher web console under **Workloads**.
{{% /onlyWhen %}}
{{< onlyWhen openshift >}}
Have a look at your awesome-app Pod inside the OpenShift web console.
{{% /onlyWhen %}}

Now delete the newly created Pod:

```bash
{{% param cliToolName %}} delete pod awesome-app --namespace <namespace>
```


## Task {{% param sectionnumber %}}.2: Create a Deployment

In some use cases it makes sense to start a single Pod but has its downsides and is not really a common practice. Let's look at another concept which is tightly coupled with the Pod: the so-called _Deployment_. A Deployment makes sure a Pod is monitored and the Deployment also checks that the number of running Pods corresponds to the number of requested Pods.

With the following command we can create a Deployment inside our already created namespace:
{{< onlyWhenNot mobi >}}

```bash
{{% param cliToolName %}} create deployment example-web-go --image=quay.io/acend/example-web-go:latest --namespace <namespace>
```

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

```bash
kubectl create deployment example-web-go --image=docker-registry.mobicorp.ch/puzzle/k8s/kurs/example-web-go --namespace <namespace>

```

{{< /onlyWhen >}}
The output should be:

```
deployment.apps/example-web-go created
```

We're using a simple sample application written in Go which you can find built as an image on [Quay.io](https://quay.io/repository/acend/example-web-go/) or its source on [GitHub](https://github.com/acend/awesome-apps).

{{% param distroName %}} creates the defined and necessary resources, pulls the container image (in this case from Docker Hub) and deploys the Pod.

Use the command `{{% param cliToolName %}} get` with the `-w` parameter in order to get the requested resources and afterwards watch for changes.

{{% alert title="Note" color="primary" %}}
The `{{% param cliToolName %}} get -w` command will never end unless you terminate it with `CTRL-c`.
{{% /alert %}}

```bash
{{% param cliToolName %}} get pods -w --namespace <namespace>
```

{{% alert title="Note" color="primary" %}}
Instead of using the `-w` parameter you can also use the `watch` command which should be available on most Linux distributions:

```bash
watch {{% param cliToolName %}} get pods --namespace <namespace>
```

{{% /alert %}}

This process can last for some time depending on your internet connection and if the image is already available locally.

{{% alert title="Note" color="primary" %}}
If you want to create your own container images and use them with {{% param distroName %}}, you definitely should have a look at [these best practices](https://docs.openshift.com/container-platform/4.4/openshift_images/create-images.html) and apply them. This image creation guide may be from OpenShift, however it also applies to Kubernetes and other container platforms.
{{% /alert %}}


## Viewing the created resources

When we executed the command `{{% param cliToolName %}} create deployment example-web-go --image=quay.io/acend/example-web-go:latest --namespace <namespace>`, {{% param distroName %}} created a Deployment resource.


### Deployment

Display the created Deployment using the following command:

```bash
{{% param cliToolName %}} get deployments --namespace <namespace>
```

A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) defines the following facts:

* Update strategy: How application updates should be executed and how the Pods are being exchanged
* Containers
  * Which image should be deployed
  * Environment configuration for Pods
  * ImagePullPolicy
* The number of Pods/Replicas that should be deployed

By using the `-o` (or `--output`) parameter we get a lot more information about the deployment itself. You can choose between YAML and JSON formatting by indicating `-o yaml` or `-o json`. In this training we are going to use YAML, but please feel free to replace `yaml` with `json` if you prefer.

```bash
{{% param cliToolName %}} get deployment example-web-go -o yaml --namespace <namespace>
```

After the image has been pulled, {{% param distroName %}} deploys a Pod according to the Deployment:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

which gives you an output similar to this:

```
NAME                              READY   STATUS    RESTARTS   AGE
example-web-go-69b658f647-xnm94   1/1     Running   0          39s
```

The deployment defines that one replica should be deployed---which is running as we can see in the output. This Pod is not yet reachable from outside of the cluster.


{{% onlyWhen rancher %}}


## Task {{% param sectionnumber %}}.3: Verify the Deployment in the Rancher web console

Try to display the logs from the example application via the Rancher Web console.
{{% /onlyWhen %}}


## Save point

{{% alert title="Note" color="primary" %}}
What's a save point? Save points are intermediate results which you can use if you are stuck. You can compare them with
your existing resources. Or you can apply the provided manifests with `{{% param cliToolName %}} apply -f <manifest.yaml>`.
{{% /alert %}}

You should now have the following resources in place:

* [deployment.yaml](deployment.yaml)
