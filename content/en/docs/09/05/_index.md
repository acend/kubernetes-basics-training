---
title: "9.5 ResourceQuota and LimitRange"
weight: 95
sectionnumber: 9.5
---

In this lab, we are going to look at ResourceQuotas and LimitRanges. As {{% param distroName %}} users, we are most certainly going to encounter the limiting effects that ResourceQuotas and LimitRanges impose.

{{% onlyWhen openshift %}}
{{% alert title="Note" color="primary" %}}
For this lab to work we are using the existing Namespace `<username>-resources`. Please make sure to always use this namespace with your commands.
{{% /alert %}}
{{% /onlyWhen %}}

{{% onlyWhenNot openshift %}}
{{% alert title="Note" color="primary" %}}
For this lab to work we are using the existing Namespace `<username>-quota`. Please make sure to always use this namespace with your commands
{{% /alert %}}
{{% /onlyWhenNot %}}


{{% onlyWhen rancher %}}


## Namespace creation

Make sure you're logged in on the Rancher web console. Choose the appropriate cluster and click on __Projects/Namespaces__. Under the Project `kubernetes-quotalab` click on __Add Namespace__.

Choose a name for your Namespace, e.g. in the form of `<yourname>`-quota, expand the __Container Default Resource Limit__ view and set the following values:

* __CPU Limit__: 100
* __CPU Reservation__: 10
* __Memory Limit__: 32
* __Memory Reservation__: 16

{{< imgproc create_quotalab_namespace.png Resize  "1000x" >}}{{< /imgproc >}}

Finally, click on __Create__.
{{% /onlyWhen %}}


## ResourceQuotas

ResourceQuotas among other things limit the amount of resources Pods can use in a Namespace. They can also be used to limit the total number of a certain resource type in a {{% onlyWhenNot openshift %}}Namespace{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}Project{{% /onlyWhen %}}. In more detail, there are these kinds of quotas:

* _Compute ResourceQuotas_ can be used to limit the amount of memory and CPU
* _Storage ResourceQuotas_ can be used to limit the total amount of storage and the number of PersistentVolumeClaims, generally or specific to a StorageClass
* _Object count quotas_ can be used to limit the number of a certain resource type such as Services, Pods or Secrets

Defining ResourceQuotas makes sense when the cluster administrators want to have better control over consumed resources. A typical use case are public offerings where users pay for a certain guaranteed amount of resources which must not be exceeded.

In order to check for defined quotas in your Namespace, simply see if there are any of type ResourceQuota:

```bash
{{% param cliToolName %}} get resourcequota --namespace <namespace>
```

To show in detail what kinds of limits the quota imposes:

```bash
{{% param cliToolName %}} describe resourcequota <quota-name> --namespace <namespace>
```

{{% onlyWhenNot openshift %}}
For more details, have look at [Kubernetes' documentation about resource quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/#requests-vs-limits).
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
For more details, have look into [OpenShift's documentation about resource quotas](https://docs.openshift.com/container-platform/latest/applications/quotas/quotas-setting-per-project.html).
{{% /onlyWhen %}}


## Requests and limits

As we've already seen, compute ResourceQuotas limit the amount of memory and CPU we can use in a {{% onlyWhenNot openshift %}}Namespace{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}Project{{% /onlyWhen %}}. Only defining a ResourceQuota, however is not going to have an effect on Pods that don't define the amount of resources they want to use. This is where the concept of limits and requests comes into play.

Limits and requests on a Pod, or rather on a container in a Pod, define how much memory and CPU this container wants to consume at least (request) and at most (limit). Requests mean that the container will be guaranteed to get at least this amount of resources, limits represent the upper boundary which cannot be crossed. Defining these values helps {{% param distroName %}} in determining on which Node to schedule the Pod because it knows how many resources should be available for it.

{{% alert title="Note" color="primary" %}}
Containers using more CPU time than what their limit allows will be throttled.
Containers using more memory than what they are allowed to use will be killed.
{{% /alert %}}

Defining limits and requests on a Pod that has one container looks like this:

```
apiVersion: v1
kind: Pod
metadata:
  name: lr-demo
  namespace: lr-example
spec:
  containers:
  - name: lr-demo-ctr
    image: {{% param "images.nginxinc-nginx-unprivileged-fix-version" %}}
    resources:
      limits:
        memory: "200Mi"
        cpu: "700m"
      requests:
        memory: "200Mi"
        cpu: "700m"
```

You can see the familiar binary unit "Mi" is used for the memory value. Other binary ("Gi", "Ki", ...) or decimal units ("M", "G", "K", ...) can be used as well.

The CPU value is denoted as "m". "m" stands for _millicpu_ or sometimes also referred to as _millicores_ where `"1000m"` is equal to one core/vCPU/hyperthread.


### Quality of service

Setting limits and requests on containers has yet another effect: It might change the Pod's _Quality of Service_ class. There are three such _QoS_ classes:

* _Guaranteed_
* _Burstable_
* _BestEffort_

The Guaranteed QoS class is applied to Pods that define both limits and requests for both memory and CPU resources on all their containers. The most important part is that each request has the same value as the limit.
Pods that belong to this QoS class will never be killed by the scheduler because of resources running out on a Node.

{{% alert title="Note" color="primary" %}}
If a container only defines its limits, {{% param distroName %}} automatically assigns a request that matches the limit.
{{% /alert %}}

The Burstable QoS class means that limits and requests on a container are set, but they are different. It is enough to define limits and requests on one container of a Pod even though there might be more, and it also only has to define limits and requests on memory or CPU, not necessarily both.

The BestEffort QoS class applies to Pods that do not define any limits and requests at all on any containers.
As its class name suggests, these are the kinds of Pods that will be killed by the scheduler first if a Node runs out of memory or CPU. As you might have already guessed by now, if there are no BestEffort QoS Pods, the scheduler will begin to kill Pods belonging to the class of _Burstable_. A Node hosting only Pods of class Guaranteed will (theoretically) never run out of resources.

{{% onlyWhenNot openshift %}}
For more examples have a look at the [Kubernetes documentation about Quality of Service](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/).
{{% /onlyWhenNot %}}


## LimitRanges

As you now know what limits and requests are, we can come back to the statement made above:

> As we've already seen, compute ResourceQuotas limit the amount of memory and CPU we can use in a Namespace. Only defining a ResourceQuota, however is not going to have an effect on Pods that don't define the amount of resources they want to use. This is where the concept of limits and requests comes into play.

So, if a cluster administrator wanted to make sure that every Pod in the cluster counted against the compute ResourceQuota, the administrator would have to have a way of defining some kind of default limits and requests that were applied if none were defined in the containers.
This is exactly what _LimitRanges_ are for.

Quoting the [Kubernetes documentation](https://kubernetes.io/docs/concepts/policy/limit-range/), LimitRanges can be used to:

* Enforce minimum and maximum compute resource usage per Pod or container in a Namespace
* Enforce minimum and maximum storage request per PersistentVolumeClaim in a Namespace
* Enforce a ratio between request and limit for a resource in a Namespace
* Set default request/limit for compute resources in a Namespace and automatically inject them to containers at runtime

If for example a container did not define any requests or limits and there was a LimitRange defining the default values, these default values would be used when deploying said container. However, as soon as limits or requests were defined, the default values would no longer be applied.

The possibility of enforcing minimum and maximum resources and defining ResourceQuotas per Namespace allows for many combinations of resource control.


### Task {{% param sectionnumber %}}.1: Namespace

Check whether your Namespace contains a LimitRange:

```bash
{{% param cliToolName %}} describe limitrange --namespace <namespace>
```

The command above should output this (name and Namespace will vary):

```
Name:       ce01a1b6-a162-479d-847c-4821255cc6db
Namespace:  eltony-quota-lab
Type        Resource  Min  Max  Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---  ---  ---------------  -------------  -----------------------
Container   memory    -    -    16Mi             32Mi           -
Container   cpu       -    -    10m              100m           -
```


Check whether a ResourceQuota exists in your Namespace:

```bash
{{% param cliToolName %}} describe quota --namespace <namespace>
```

The command above will produce an output similar to the following (name and namespace may vary)

```
Name:            lab-quota
Namespace:       eltony-quota-lab
Resource         Used  Hard
--------         ----  ----
requests.cpu     0     100m
requests.memory  0     100Mi
```


## Task {{% param sectionnumber %}}.2: Default memory limit

Create a Pod using the stress image:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: stress2much
spec:
  containers:
  - command:
    - stress
    - --vm
    - "1"
    - --vm-bytes
    - 85M
    - --vm-hang
    - "1"
    image: {{% param "images.stress" %}}
    imagePullPolicy: Always
    name: stress
```

Apply this resource with:

```bash
{{% param cliToolName %}} apply -f pod_stress2much.yaml
```


{{% alert title="Note" color="primary" %}}
You have to actively terminate the following command pressing `CTRL+c` on your keyboard.
{{% /alert %}}

Watch the Pod's creation with:

```bash
{{% param cliToolName %}} get pods --watch --namespace <namespace>
```

You should see something like the following:

```
NAME          READY   STATUS              RESTARTS   AGE
stress2much   0/1     ContainerCreating   0          1s
stress2much   0/1     ContainerCreating   0          2s
stress2much   0/1     OOMKilled           0          5s
stress2much   1/1     Running             1          7s
stress2much   0/1     OOMKilled           1          9s
stress2much   0/1     CrashLoopBackOff    1          20s
```

The `stress2much` Pod was OOM (out of memory) killed. We can see this in the `STATUS` field. Another way to find out why a Pod was killed is by checking its status. Output the Pod's YAML definition:

```bash
{{% param cliToolName %}} get pod stress2much --output yaml --namespace <namespace>
```

Near the end of the output you can find the relevant status part:
```yaml
  containerStatuses:
  - containerID: docker://da2473f1c8ccdffbb824d03689e9fe738ed689853e9c2643c37f206d10f93a73
    image: {{% param "images.stress" %}}
    lastState:
      terminated:
        ...
        reason: OOMKilled
        ...
```

So let's look at the numbers to verify the container really had too little memory. We started the `stress` command using the parameter `--vm-bytes 85M` which means the process wants to allocate 85 megabytes of memory. Again looking at the Pod's YAML definition with:

```bash
{{% param cliToolName %}} get pod stress2much --output yaml --namespace <namespace>
```

reveals the following values:

```
...
    resources:
      limits:
        cpu: 100m
        memory: 32Mi
      requests:
        cpu: 10m
        memory: 16Mi
...
```

These are the values from the LimitRange, and the defined limit of 32 MiB of memory prevents the `stress` process of ever allocating the desired 85 MB.

Let's fix this by recreating the Pod and explicitly setting the memory request to 85 MB.

First, delete the `stress2much` pod with:


```bash
{{% param cliToolName %}} delete pod stress2much --namespace <namespace>
```

Then create a new Pod where the requests and limits are set:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: stress
spec:
  containers:
  - command:
    - stress
    - --vm
    - "1"
    - --vm-bytes
    - 85M
    - --vm-hang
    - "1"
    image: {{% param "images.stress" %}}
    imagePullPolicy: Always
    name: stress
    resources:
      limits:
        cpu: 100m
        memory: 100Mi
      requests:
        cpu: 10m
        memory: 85Mi
```

And apply this again with:

```bash
{{% param cliToolName %}} apply -f pod_stress.yaml
```

{{% alert title="Note" color="primary" %}}
Remember, if you only set the limit, the request will be set to the same value.
{{% /alert %}}

You should now see that the Pod is successfully running:

```
NAME     READY   STATUS    RESTARTS   AGE
stress   1/1     Running   0          25s
```


## Task {{% param sectionnumber %}}.3: Hitting the quota

Create another Pod, again using the `stress` image. This time our application is less demanding and only needs 10 MB of memory (`--vm-bytes 10M`):

Create a new Pod resource with:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: overbooked
spec:
  containers:
  - command:
    - stress
    - --vm
    - "1"
    - --vm-bytes
    - 10M
    - --vm-hang
    - "1"
    image: {{% param "images.stress" %}}
    imagePullPolicy: Always
    name: overbooked
```

```bash
{{% param cliToolName %}} apply -f pod_overbooked.yaml
```

We are immediately confronted with an error message:

```
Error from server (Forbidden): pods "overbooked" is forbidden: exceeded quota: lab-quota, requested: memory=16Mi, used: memory=85Mi, limited: memory=100Mi
```

The default request value of 16 MiB of memory that was automatically set on the Pod lets us hit the quota which in turn prevents us from creating the Pod.

Let's have a closer look at the quota with:

```bash
{{% param cliToolName %}} get quota --output yaml --namespace <namespace>
```

which should output the following YAML definition:

```
...
  status:
    hard:
      cpu: 100m
      memory: 100Mi
    used:
      cpu: 20m
      memory: 80Mi
...
```

The most interesting part is the quota's status which reveals that we cannot use more than 100 MiB of memory and that 80 MiB are already used.

Fortunately, our application can live with less memory than what the LimitRange sets. Let's set the request to the remaining 10 MiB:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: overbooked
spec:
  containers:
  - command:
    - stress
    - --vm
    - "1"
    - --vm-bytes
    - 10M
    - --vm-hang
    - "1"
    image: {{% param "images.stress" %}}
    imagePullPolicy: Always
    name: overbooked
    resources:
      limits:
        cpu: 100m
        memory: 50Mi
      requests:
        cpu: 10m
        memory: 10Mi
```

And apply with:

```bash
{{% param cliToolName %}} apply -f pod_overbooked.yaml
```

Even though the limits of both Pods combined overstretch the quota, the requests do not and so the Pods are allowed to run.
