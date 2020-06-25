---
title: "4. Deploy a Docker image"
weight: 4
sectionnumber: 4
---

In this lab, we are going to deploy our first pre-built container image and look at the Kubernetes concepts Pod, Service, and Deployment.


## Task {{% param sectionnumber %}}.1: Start and stop a single Pod

After we've familiarized ourselves with the platform, we are going to have a look at deploying a pre-built container image from Docker Hub or any other public Container registry.

First, we are going to directly start a new Pod:

{{< onlyWhenNot mobi >}}

```bash
kubectl run nginx --image=nginx --port=80 --restart=Never --namespace <namespace>
```

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

```bash
kubectl run nginx --image=docker-registry.mobicorp.ch/puzzle/k8s/kurs/nginx:stable --port=80 --restart=Never --namespace <namespace>
```

{{< /onlyWhen >}}

Use `kubectl get pods --namespace <namespace>` in order to show the running Pod:

```bash
kubectl get pods --namespace <namespace>
```

Which gives you an output similar to this:

```
NAME      READY     STATUS    RESTARTS   AGE
nginx     1/1       Running   0          1m
```

{{% onlyWhen rancher %}}
Have a look at your nginx Pod inside the Rancher web console under **Workloads**.
{{% /onlyWhen %}}

Now delete the newly created Pod:

```bash
kubectl delete pod nginx --namespace <namespace>
```


## Task {{% param sectionnumber %}}.2: Create a Deployment

In some use cases it makes sense to start a single Pod but has its downsides and is not really a common practice. Let's look at another Kubernetes concept which is tightly coupled with the Pod: the so-called _Deployment_. A Deployment makes sure a Pod is monitored and the Deployment also checks that the number of running Pods corresponds to the number of requested Pods.

With the following command we can create a Deployment inside our already created namespace:
{{< onlyWhenNot mobi >}}

```bash
kubectl create deployment example-web-go --image=acend/example-web-go --namespace <namespace>
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

We're using an example from us (a simple Go application), which you can find on [Docker Hub](https://hub.docker.com/r/acend/example-web-go/) and [GitHub (Source)](https://github.com/acend/awesome-apps).

Kubernetes creates the defined and necessary resources, pulls the container image (in this case from Docker Hub) and deploys the Pod.

Use the command `kubectl get` with the `-w` parameter in order to get the requested resources and afterwards watch for changes. (This command will never end unless you terminate it with `CTRL-c`):


```bash
kubectl get pods -w --namespace <namespace>
```

This process can last for some time depending on your Internet connection and if the image is already available locally.

{{% alert title="Note" color="primary" %}}
If you want to create your own container images and use them with Kubernetes, you definitely should have a look at [these best practices](https://docs.openshift.com/container-platform/4.4/openshift_images/create-images.html) and apply them. This image creation guide may be from OpenShift, however it also applies to Kubernetes and other container platforms.
{{% /alert %}}


## Viewing the created resources

When we executed the command `kubectl create deployment example-web-go --image=acend/example-web-go --namespace <namespace>`, Kubernetes created a deployment resource.


### Deployment

Display the created deployment using the following command:

```bash
kubectl get deployments --namespace <namespace>
```

A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) defines the following facts:

* Update strategy: How application updates should be executed and how the Pods are being exchanged
* Containers
  * Which image should be deployed
  * Environment configuration for Pods
  * ImagePullPolicy
* The number of Pods/Replicas that should be deployed

By using the `-o` (or `--output`) parameter we get a lot more information about the deployment itself:

```bash
kubectl get deployment example-web-go -o json --namespace <namespace>
```

After the image has been pulled, Kubernetes deploys a Pod according to the Deployment:

```bash
kubectl get pods --namespace <namespace>
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
