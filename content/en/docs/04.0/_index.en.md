---
title: "4. Deploy a Docker Image"
weight: 4
---

In this lab, we are going to deploy our first pre-built container image and look at the Kubernetes concepts pod, service and deployment.


## Task: Start a Pod

After we've familiarized ourselves with the platform, we are going to have a look at deploying a pre-built container image from Docker Hub or any other public Container registry.

First, we are going to directly start a new pod:

```bash
kubectl run nginx --image=nginx --port=80 --restart=Never --namespace <NAMESPACE>
```

Use `kubectl get pods --namespace <NAMESPACE>` in order to show the running pod:

```bash
kubectl get pods --namespace <NAMESPACE>
```

which give you an output similar to this:

```
NAME      READY     STATUS    RESTARTS   AGE
nginx     1/1       Running   0          1m
```

{{% onlyWhen rancher %}}
Have a look at your nginx pod inside the Rancher WebGUI under "Workloads" an delete the pod right afterwards.
{{% /onlyWhen %}}


## Task: Deployment

In some usecases it makes sense to start a single pod but has its downsides and is not really best practice. Let's look at another Kubernetes concept which is tightly coupled with the pod: the so-called deployment. A deployment makes sure that a pod is monitored and checks that the number of running pods corresponds to the number of requested pods.

With the following command we can create a deployment inside our already created namespace:

```bash
kubectl create deployment example-web-go --image=acend/example-web-go --namespace <NAMESPACE>
```

The output should be:
```
deployment.apps/example-web-go created
```

We're using an example from us (a simple Golang application), which you can find on [Docker Hub](https://hub.docker.com/r/acend/example-web-go/) and [GitHub (Source)](https://github.com/acend/awesome-apps).

Kubernetes creates the defined and necessary resources, pulls the container image (in this case from Docker Hub) and deploys the pod.

Use the command `kubectl get` with the `-w` parameter in order to get the requested resources and afterwards watch for changes. (**This command will never end unless you terminate it with ctrl+c**):


```bash
kubectl get pods --namespace <NAMESPACE> -w
```

This process can last for some time depending on your internet connection and if the image is already available locally.

{{% alert title="Tip" color="warning" %}}
If you want to create your own container images and use them with Kubernetes, you definitely should have a look at [these best practices](https://docs.openshift.com/container-platform/latest/creating_images/guidelines.html) and apply them. The Image Creation Guide may be from OpenShift, however it also applies to Kubernetes and other container platforms.
{{% /alert %}}


## Viewing the Created Resources

When we executed the command `kubectl create deployment example-web-go --image=acend/example-web-go --namespace <NAMESPACE>`, Kubernetes created a deployment resource.


### Deployment

Display the created deployment using the following command:

```bash
kubectl get deployment --namespace <NAMESPACE>
```

A [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) defines the following facts:

- Update strategy: How application updates should be executed and how the pods are being exchanged
- Containers
  - Which image should be deployed
  - Environment configuration for pods
  - ImagePullPolicy
- The number of pods/replicas that should be deployed

By using the `-o` (or `--output`) parameter we get a lot more information about the deployment itself:

```bash
kubectl get deployment example-web-go -o json --namespace <NAMESPACE>
```

After the image has been pulled, Kubernetes deploys a pod according to the deployment:

```bash
kubectl get pod --namespace <NAMESPACE>
```

which gives you an output similar to this:
```
NAME                              READY   STATUS    RESTARTS   AGE
example-web-go-69b658f647-xnm94   1/1     Running   0          39s
nginx                             1/1     Running   0          31m
```

The deployment defines that one replica should be deployed, which is running as we can see in the output. This pod is not yet reachable from outside of the cluster.


{{% onlyWhen rancher %}}
## Task: Verify the Deployment in the Rancher WebGUI

Try to display the logs from the example application via the Rancher WebGui.
{{% /onlyWhen %}}
