---
title: "Scaling"
weight: 5
---

In this lab, we are going to show you how to scale applications on {{% param distroName %}}. Furthermore, we show you how {{% param distroName %}} makes sure that the number of requested Pods is up and running and how an application can tell the platform that it is ready to receive requests.

{{% alert title="Note" color="info" %}}
This lab does not depend on previous labs. You can start with an empty Namespace.
{{% /alert %}}


## {{% task %}} Scale the example application

Create a new Deployment in your Namespace. So again, lets define the Deployment using YAML in a file `05_deployment.yaml` with the following content:

{{% onlyWhenNot sbb %}}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: example-web-app
  name: example-web-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: example-web-app
  template:
    metadata:
      labels:
        app: example-web-app
    spec:
      containers:
        - image: {{% param "images.training-image-url" %}}
          name: example-web-app
          resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 50m
              memory: 128Mi
```

{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}
{{< readfile file="/content/en/docs/scaling/example-web-app-deployment-java.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}

```bash
{{% param cliToolName %}} apply -f 05_deployment.yaml --namespace <namespace>
```

If we want to scale our example application, we have to tell the Deployment that we want to have three running replicas instead of one.
Let's have a closer look at the existing ReplicaSet:

```bash
{{% param cliToolName %}} get replicasets --namespace <namespace>
```

Which will give you an output similar to this:

```
NAME                            DESIRED   CURRENT   READY   AGE
example-web-app-86d9d584f8      1         1         1       110s
```

Or for even more details:

```bash
{{% param cliToolName %}} get replicaset <replicaset> -o yaml --namespace <namespace>
```

The ReplicaSet shows how many instances of a Pod are desired, current and ready.

Now we scale our application to three replicas:

```bash
{{% param cliToolName %}} scale deployment example-web-app --replicas=3 --namespace <namespace>
```

Check the number of desired, current and ready replicas:

```bash
{{% param cliToolName %}} get replicasets --namespace <namespace>
```

```
NAME                            DESIRED   CURRENT   READY   AGE
example-web-app-86d9d584f8      3         3         3       4m33s

```

Look at how many Pods there are:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

Which gives you an output similar to this:

```
NAME                                  READY   STATUS    RESTARTS   AGE
example-web-app-86d9d584f8-7vjcj      1/1     Running   0          5m2s
example-web-app-86d9d584f8-hbvlv      1/1     Running   0          31s
example-web-app-86d9d584f8-qg499      1/1     Running   0          31s
```

{{% onlyWhenNot openshift %}}
{{% alert title="Note" color="info" %}}
Kubernetes even supports [autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).
{{% /alert %}}
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
{{% alert title="Note" color="info" %}}
OpenShift supports [horizontal](https://docs.openshift.com/container-platform/latest/nodes/pods/nodes-pods-autoscaling.html) and [vertical autoscaling](https://docs.openshift.com/container-platform/latest/nodes/pods/nodes-pods-vertical-autoscaler.html).
{{% /alert %}}
{{% /onlyWhen %}}


## Check for uninterruptible Deployments

{{% onlyWhenNot openshift %}}
Now we create a new Service of the type `ClusterIP`:

```bash
kubectl expose deployment example-web-app --type="ClusterIP" --name="example-web-app" --port={{% param "images.training-image-port" %}} --target-port={{% param "images.training-image-port" %}} --namespace <namespace>
```

and we need to create an Ingress to access the application:

{{% onlyWhenNot customer %}}
{{< readfile file="/content/en/docs/scaling/ingress.template.yaml" code="true" lang="yaml" >}}
{{% /onlyWhenNot %}}

{{% onlyWhen mobi %}}
{{< readfile file="/content/en/docs/scaling/ingress-mobi.template.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}

Apply this Ingress definition using, e.g., `kubectl create -f ingress.yaml --namespace <namespace>`

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Now we expose our application to the internet by creating a service and a route.

First the Service:

```bash
oc expose deployment example-web-app --name="example-web-app" --port={{% param "images.training-image-port" %}} --namespace <namespace>
```

Then the Route:

{{% onlyWhenNot baloise %}}

```bash
oc expose service example-web-app --namespace <namespace>
```

{{% /onlyWhenNot %}}
{{% onlyWhen baloise %}}

```bash
oc create route edge example-web-app --service example-web-app --namespace <namespace>
```

{{% /onlyWhen %}}

{{% /onlyWhen %}}

Let's look at our Service. We should see all three corresponding Endpoints:

```bash
{{% param cliToolName %}} describe service example-web-app --namespace <namespace>
```

{{% onlyWhenNot openshift %}}

```
Name:                     example-web-app
Namespace:                acend-scale
Labels:                   app=example-web-app
Annotations:              <none>
Selector:                 app=example-web-app
Type:                     ClusterIP
IP:                       10.39.245.205
Port:                     <unset>  {{% param "images.training-image-port" %}}/TCP
TargetPort:               {{% param "images.training-image-port" %}}/TCP
Endpoints:                10.36.0.10:{{% param "images.training-image-port" %}},10.36.0.11:{{% param "images.training-image-port" %}},10.36.0.9:{{% param "images.training-image-port" %}}
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}

```
Name:              example-web-app
Namespace:         acend-test
Labels:            app=example-web-app
Annotations:       <none>
Selector:          app=example-web-app
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                172.30.89.44
IPs:               172.30.89.44
Port:              <unset>  {{% param "images.training-image-port" %}}/TCP
TargetPort:        {{% param "images.training-image-port" %}}/TCP
Endpoints:         10.125.4.70:{{% param "images.training-image-port" %}},10.126.4.137:{{% param "images.training-image-port" %}},10.126.4.138:{{% param "images.training-image-port" %}}
Session Affinity:  None
Events:            <none>
```

{{% /onlyWhen %}}

Scaling of Pods is fast as {{% param distroName %}} simply creates new containers.

You can check the availability of your Service while you scale the number of replicas up and down in your browser: `{{% onlyWhenNot openshift %}}http://example-web-app-<namespace>.<domain>{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}http://<route hostname>{{% /onlyWhen %}}`.

{{% onlyWhen openshift %}}
{{% alert title="Note" color="info" %}}
You can find out the route's hostname by looking at the output of `oc get route`.
{{% /alert %}}
{{% /onlyWhen %}}

Now, execute the corresponding loop command for your operating system in another console.

Linux:

{{% onlyWhen openshift %}}

```bash
URL=$(oc get routes example-web-app -o go-template="{{ .spec.host }}" --namespace <namespace>)
while true; do sleep 1; curl -s http://${URL}/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
{{% onlyWhenNot mobi %}}

```bash
URL=example-web-app-<namespace>.<domain>
while true; do sleep 1; curl -s http://${URL}/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}

```bash
URL=example-web-app-<namespace>.<appdomain>
while true; do sleep 1; curl -ks https://${URL}/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

{{% /onlyWhen %}}

{{% /onlyWhenNot %}}

Windows PowerShell:

```bash
while(1) {
  Start-Sleep -s 1
  Invoke-RestMethod http://<URL>/pod/
  Get-Date -Uformat "+ TIME: %H:%M:%S,%3N"
}
```

Scale from 3 replicas to 1.
The output shows which Pod is still alive and is responding to requests:

```
example-web-app-86d9d584f8-7vjcj TIME: 17:33:07,289
example-web-app-86d9d584f8-7vjcj TIME: 17:33:08,357
example-web-app-86d9d584f8-hbvlv TIME: 17:33:09,423
example-web-app-86d9d584f8-7vjcj TIME: 17:33:10,494
example-web-app-86d9d584f8-qg499 TIME: 17:33:11,559
example-web-app-86d9d584f8-hbvlv TIME: 17:33:12,629
example-web-app-86d9d584f8-qg499 TIME: 17:33:13,695
example-web-app-86d9d584f8-hbvlv TIME: 17:33:14,771
example-web-app-86d9d584f8-hbvlv TIME: 17:33:15,840
example-web-app-86d9d584f8-7vjcj TIME: 17:33:16,912
example-web-app-86d9d584f8-7vjcj TIME: 17:33:17,980
example-web-app-86d9d584f8-7vjcj TIME: 17:33:19,051
example-web-app-86d9d584f8-7vjcj TIME: 17:33:20,119
example-web-app-86d9d584f8-7vjcj TIME: 17:33:21,182
example-web-app-86d9d584f8-7vjcj TIME: 17:33:22,248
example-web-app-86d9d584f8-7vjcj TIME: 17:33:23,313
example-web-app-86d9d584f8-7vjcj TIME: 17:33:24,377
example-web-app-86d9d584f8-7vjcj TIME: 17:33:25,445
example-web-app-86d9d584f8-7vjcj TIME: 17:33:26,513
```

The requests get distributed amongst the three Pods. As soon as you scale down to one Pod, there should be only one remaining Pod that responds.

Let's make another test: What happens if you start a new Deployment while our request generator is still running?

```bash
{{% param cliToolName %}} rollout restart deployment example-web-app --namespace <namespace>
```

During a short period we won't get a response:

{{% onlyWhenNot sbb %}}

```
example-web-app-86d9d584f8-7vjcj TIME: 17:37:24,121
example-web-app-86d9d584f8-7vjcj TIME: 17:37:25,189
example-web-app-86d9d584f8-7vjcj TIME: 17:37:26,262
example-web-app-86d9d584f8-7vjcj TIME: 17:37:27,328
example-web-app-86d9d584f8-7vjcj TIME: 17:37:28,395
example-web-app-86d9d584f8-7vjcj TIME: 17:37:29,459
example-web-app-86d9d584f8-7vjcj TIME: 17:37:30,531
example-web-app-86d9d584f8-7vjcj TIME: 17:37:31,596
example-web-app-86d9d584f8-7vjcj TIME: 17:37:32,662
# no answer
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:33,729
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:34,794
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:35,862
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:36,929
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:37,995
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:39,060
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:40,118
example-web-app-f4c5dd8fc-4nx2t TIME: 17:37:41,187
```

In our example, we use a very lightweight Pod. If we had used a more heavyweight Pod that needed a longer time to respond to requests, we would of course see a larger gap.
An example for this would be a Java application with a startup time of 30 seconds:
{{% /onlyWhenNot %}}

```
example-spring-boot-2-73aln TIME: 16:48:25,251
example-spring-boot-2-73aln TIME: 16:48:26,305
example-spring-boot-2-73aln TIME: 16:48:27,400
example-spring-boot-2-73aln TIME: 16:48:28,463
example-spring-boot-2-73aln TIME: 16:48:29,507
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:33,562
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:34,601
 ...
example-spring-boot-3-tjdkj TIME: 16:49:20,114
example-spring-boot-3-tjdkj TIME: 16:49:21,181
example-spring-boot-3-tjdkj TIME: 16:49:22,231

```

It is even possible that the Service gets down, and the routing layer responds with the status code 503 as can be seen in the example output above.

In the following chapter we are going to look at how a Service can be configured to be highly available.


## Uninterruptible Deployments

The [rolling update strategy](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/) makes it possible to deploy Pods without interruption. The rolling update strategy means that the new version of an application gets deployed and started. As soon as the application says it is ready, {{% param distroName %}} forwards requests to the new instead of the old version of the Pod, and the old Pod gets terminated.

Additionally, [container health checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/) help {{% param distroName %}} to precisely determine what state the application is in.

Basically, there are two different kinds of checks that can be implemented:

* Liveness probes are used to find out if an application is still running
* Readiness probes tell us if the application is ready to receive requests (which is especially relevant for the above-mentioned rolling updates)

These probes can be implemented as HTTP checks, container execution checks (the execution of a command or script inside a container) or TCP socket checks.

In our example, we want the application to tell {{% param distroName %}} that it is ready for requests with an appropriate readiness probe.
{{% onlyWhenNot sbb %}}
Our example application has a health check context named health: `{{% onlyWhenNot openshift %}}http://<node-ip>:<node-port>/health{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}http://${URL}/health{{% /onlyWhen %}}`
{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}
Our example application has a health check context named health: `http://localhost:{{% param "images.training-image-probe-port" %}}/health`. This port is not exposed by a service. It is only accessible inside the cluster.
{{% /onlyWhen %}}


## {{% task %}} Availability during deployment

{{% onlyWhenNot openshift %}}
In our deployment configuration inside the rolling update strategy section, we define that our application always has to be available during an update: `maxUnavailable: 0`

You can directly edit the deployment (or any resource) with:

```bash
kubectl edit deployment example-web-app --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
If you're not comfortable with `vi` then you can switch to another editor by setting the environment variable `EDITOR`
or `KUBE_EDITOR`, e.g. `export KUBE_EDITOR=nano`.
{{% /alert %}}

Look for the following section and change the value for `maxUnavailable` to 0:

```
...
spec:
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 0
    type: RollingUpdate
...
```

Now insert the readiness probe at `.spec.template.spec.containers` above the `resources: {}` line:

```yaml

...
containers:
  - image: {{% param "images.training-image-url" %}}
    imagePullPolicy: Always
    name: example-web-app
    # start to copy here
    readinessProbe:
      httpGet:
        path: /health
        port: {{% param "images.training-image-probe-port" %}}
        scheme: HTTP
      initialDelaySeconds: 10
      timeoutSeconds: 1
    # stop to copy here
    resources: {}
...
```

The `containers` configuration then looks like:

```yaml

...
containers:
  - image: {{% param "images.training-image-url" %}}
    imagePullPolicy: Always
    name: example-web-app
    readinessProbe:
      failureThreshold: 3
      httpGet:
        path: /health
        port: {{% param "images.training-image-probe-port" %}}
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 1
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
...
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Define the readiness probe on the Deployment using the following command:

```bash
oc set probe deploy/example-web-app --readiness --get-url=http://:{{% param "images.training-image-probe-port" %}}/health --initial-delay-seconds=10 --timeout-seconds=1 --namespace <namespace>
```

The command above results in the following `readinessProbe` snippet being inserted into the Deployment:

```yaml

...
containers:
  - image: {{% param "images.training-image-url" %}}
    imagePullPolicy: Always
    name: example-web-app
    readinessProbe:
      httpGet:
        path: /health
        port: {{% param "images.training-image-probe-port" %}}
        scheme: HTTP
      initialDelaySeconds: 10
      timeoutSeconds: 1
...
```

{{% /onlyWhen %}}

We are now going to verify that a redeployment of the application does not lead to an interruption.

Set up the loop again to periodically check the application's response (you don't have to set the `$URL` variable again if it is still defined):

{{% onlyWhen openshift %}}

```bash
URL=$(oc get routes example-web-app -o go-template="{{ .spec.host }}" --namespace <namespace>)
while true; do sleep 1; curl -s http://${URL}/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}

```bash
URL=example-web-app-<namespace>.<domain>
while true; do sleep 1; curl -s http://${URL}/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

{{% /onlyWhenNot %}}

Windows PowerShell:

```bash
while(1) {
  Start-Sleep -s 1
  Invoke-RestMethod http://[URL]/pod/
  Get-Date -Uformat "+ TIME: %H:%M:%S,%3N"
}
```

{{% onlyWhenNot openshift %}}
Start a new deployment by editing it (the so-called _ConfigChange_ trigger creates the new Deployment automatically):

```bash
kubectl patch deployment example-web-app -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}" --namespace <namespace>
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Start a new deployment:

```bash
oc rollout restart deployment example-web-app --namespace <namespace>
```

{{% /onlyWhen %}}


## Self-healing

Via the {{% onlyWhenNot openshift %}}Replicaset{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}Deployment definition{{% /onlyWhen %}} we told {{% param distroName %}} how many replicas we want. So what happens if we simply delete a Pod?

Look for a running Pod (status `RUNNING`) that you can bear to kill via `{{% param cliToolName %}} get pods`.

Show all Pods and watch for changes:

```bash
{{% param cliToolName %}} get pods -w --namespace <namespace>
```

Now delete a Pod (in another terminal) with the following command:

```bash
{{% param cliToolName %}} delete pod <pod> --namespace <namespace>
```

Observe how {{% param distroName %}} instantly creates a new Pod in order to fulfill the desired number of running instances.
