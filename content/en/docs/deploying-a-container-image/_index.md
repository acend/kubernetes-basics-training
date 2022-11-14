---
title: "Deploying a container image"
weight: 3
---

In this lab, we are going to deploy our first container image and look at the concepts of Pods, Services, and Deployments.


## {{% task %}} Start and stop a single Pod

After we've familiarized ourselves with the platform, we are going to have a look at deploying a pre-built container image from Quay.io or any other public container registry.

{{% onlyWhen openshift %}}
In OpenShift we have used the `<project>` identifier to select the correct project. Please use the same identifier in the context `<namespace>` to do the same for all upcoming labs. Ask your trainer if you want more information on that.
{{% /onlyWhen %}}

First, we are going to directly start a new Pod. For this we have to define our Kubernetes Pod resource definition. Create a new file `03_pod.yaml` with the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: awesome-app
spec:
  containers:
  - image: {{% param "images.deployment-image-url" %}}
    imagePullPolicy: Always
    name: awesome-app
    resources:
      limits:
        cpu: 20m
        memory: 32Mi
      requests:
        cpu: 10m
        memory: 16Mi

```

Now we can apply this with:

```bash
{{% param cliToolName %}} apply -f 03_pod.yaml --namespace <namespace>
```

The output should be:

```
pod/awesome-app created
```

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
{{% onlyWhen openshift %}}
Have a look at your awesome-app Pod inside the OpenShift web console.
{{% /onlyWhen %}}

Now delete the newly created Pod:

```bash
{{% param cliToolName %}} delete pod awesome-app --namespace <namespace>
```


## {{% task %}} Create a Deployment

In some use cases it can make sense to start a single Pod. But this has its downsides and is not really a common practice. Let's look at another concept which is tightly coupled with the Pod: the so-called _Deployment_. A Deployment ensures that a Pod is monitored and checks that the number of running Pods corresponds to the number of requested Pods.


To create a new Deployment we first define our Deployment in a new file `03_deployment.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: example-web-go
  name: example-web-go
spec:
  replicas: 1
  selector:
    matchLabels:
      app: example-web-go
  template:
    metadata:
      labels:
        app: example-web-go
    spec:
      containers:
      - image: {{% param "images.deployment-image-url" %}}
        name: example-web-go
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
          limits:
            cpu: 20m
            memory: 32Mi
```

And with this we create our Deployment inside our already created namespace:


```bash
{{% param cliToolName %}} apply -f 03_deployment.yaml --namespace <namespace>
```

The output should be:

```
deployment.apps/example-web-go created
```

We're using a simple sample application written in Go, which you can find built as an image on [Quay.io](https://quay.io/repository/acend/example-web-go/) or as source code on [GitHub](https://github.com/acend/awesome-apps).

{{% param distroName %}} creates the defined and necessary resources, pulls the container image (in this case from Quay.io) and deploys the Pod.

Use the command `{{% param cliToolName %}} get` with the `-w` parameter in order to get the requested resources and afterward watch for changes.

{{% alert title="Note" color="info" %}}
The `{{% param cliToolName %}} get -w` command will never end unless you terminate it with `CTRL-c`.
{{% /alert %}}

```bash
{{% param cliToolName %}} get pods -w --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
Instead of using the `-w` parameter you can also use the `watch` command which should be available on most Linux distributions:

```bash
watch {{% param cliToolName %}} get pods --namespace <namespace>
```

{{% /alert %}}

This process can last for some time depending on your internet connection and if the image is already available locally.

{{% alert title="Note" color="info" %}}
If you want to create your own container images and use them with {{% param distroName %}}, you definitely should have a look at [these best practices](https://docs.openshift.com/container-platform/latest/openshift_images/create-images.html) and apply them. This image creation guide may be for OpenShift, however it also applies to Kubernetes and other container platforms.
{{% /alert %}}


### Creating Kubernetes resources

There are two fundamentally different ways to create Kubernetes resources.
You've already seen one way: Writing the resource's definition in YAML (or JSON) and then applying it on the cluster using `{{% param cliToolName %}} apply`.

The other variant is to use helper commands. These are more straightforward: You don't have to copy a YAML definition from somewhere else and then adapt it.
However, the result is the same. The helper commands just simplify the process of creating the YAML definitions.

As an example, let's look at creating above deployment, this time using a helper command instead. If you already created the Deployment using above YAML definition, you don't have to execute this command:

```yaml
{{% param cliToolName %}} create deployment example-web-go --image={{% param "images.deployment-image-url" %}} --namespace <namespace>
```

It's important to know that these helper commands exist.
However, in a world where GitOps concepts have an ever-increasing presence, the idea is not to constantly create these resources with helper commands.
Instead, we save the resources' YAML definitions in a Git repository and leave the creation and management of those resources to a tool.


## {{% task %}} Viewing the created resources

Display the created Deployment using the following command:

```bash
{{% param cliToolName %}} get deployments --namespace <namespace>
```

A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) defines the following facts:

* Update strategy: How application updates should be executed and how the Pods are exchanged
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

The Deployment defines that one replica should be deployed --- which is running as we can see in the output. This Pod is not yet reachable from outside the cluster.

{{% onlyWhen openshift %}}


## {{% task %}} Verify the Deployment in the {{% param distroName %}} web console

Try to display the logs from the example application in the {{% param distroName %}} web console.
{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
{{% onlyWhenNot baloise %}}


## {{% task %}} Build the image yourself

Up until now, we've used pre-built images from Quay.io. OpenShift offers the ability to build images on the cluster itself using different [strategies](https://docs.openshift.com/container-platform/latest/cicd/builds/understanding-image-builds.html):

* Docker build strategy
* Source-to-image build strategy
* Custom build strategy
* Pipeline build strategy

We are going to use the Docker build strategy. It expects:

> [...] a repository with a Dockerfile and all required artifacts in it to produce a runnable image.

All of these requirements are already fulfilled in the [source code repository on GitHub](https://github.com/acend/awesome-apps/tree/main/go), so let's build the image!
{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
{{% alert title="Note" color="info" %}}
Have a look at [OpenShift's documentation](https://docs.openshift.com/container-platform/latest/cicd/builds/understanding-image-builds.html) to learn more about the other available build strategies.
{{% /alert %}}
{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
First we clean up the already existing Deployment:

```bash
oc delete deployment example-web-go --namespace <namespace>
```

We are now ready to create the build and deployment, all in one command:

```bash
oc new-app --name example-web-go --labels app=example-web-go --context-dir go/ --strategy docker https://github.com/acend/awesome-apps.git --namespace <namespace>
```

Let's watch the image's build process:

```bash
oc logs bc/example-web-go --follow --namespace <namespace>
```

The message `Push successful` signifies the image's successful build and push to OpenShift's internal image.

In the above command you discovered a new resource type `bc` which is the abbreviation for _BuildConfig_.
A BuildConfig defines how a container image has to be built.

A _Build_ resource represents the build process itself based upon the BuildConfig's definition.
A build takes place in a Pod on OpenShift, so instead of referencing the BuildConfig in our `oc logs` command, we could have used the build Pod's log output.
However, referencing the BuildConfig has the advantage that it can be reused each time a build is run.
A build Pod changes its name with every build.

Have a look at the new Deployment created by the `oc new-app` command:

```bash
oc get deployment example-web-go -o yaml --namespace <namespace>
```

It looks the same as before with the only essential exception that it uses the image we just built instead of the pre-built image from Quay.io:

```
    ...
    spec:
      containers:
      - image: image-registry.openshift-image-registry.svc:5000/<namespace>/awesome-app@sha256:4cd671273a837453464f7264afe845b299297ebe032f940fd005cf9c40d1e76c
      ...
```

{{% /onlyWhenNot %}}
{{% /onlyWhen %}}


## Save point

{{% alert title="Note" color="info" %}}
What's a save point? Save points are intermediate results which you can use if you are stuck. You can compare them with
your existing resources or you can apply the provided manifests with `{{% param cliToolName %}} apply -f <manifest.yaml>`.
{{% /alert %}}

You should now have the following resources in place:

* [deployment.yaml](deployment.yaml)
