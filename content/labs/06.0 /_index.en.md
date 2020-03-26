---
title: "6.0 - Scaling"
weight: 60
---

# Lab 6: Scaling

In this lab we are going to show you how to scale applications on Kubernetes. Further we show you how Kubernetes makes sure that the number of requested pods is up and running how an application can tell the platform that it is ready to ready to receive request.



## Task: LAB6.1 Scale the Example Application

Create a new deployment in your namespace:


```
$ kubectl create deployment appuio-php-docker --image=appuio/example-php-docker-helloworld --namespace [TEAM]-dockerimage
```

If we want to scale our example application, we have to tell the deployment that we e.g. want to have three running replicas instead of one.

Let's have a closer look at the existing replicaset:


```
$ kubectl get replicasets --namespace [TEAM]-dockerimage

NAME                           DESIRED   CURRENT   READY   AGE
appuio-php-docker-86d9d584f8   1         1         1       110s
```

Or for even more details:

```
$ kubectl get replicaset appuio-php-docker-86d9d584f8 -o json --namespace [TEAM]-dockerimage
```

The replicaset shows how many pods/replicas are desired, current and ready.


Now we scale our application to three replicas:

```
$ kubectl scale deployment appuio-php-docker --replicas=3 --namespace [TEAM]-dockerimage
```

Check the number of desired, current and ready replicas:

```
$ kubectl get replicasets --namespace [TEAM]-dockerimage

NAME                           DESIRED   CURRENT   READY   AGE
appuio-php-docker-86d9d584f8   3         3         1       4m33s

```

and look at how many pods there are:

```
$ kubectl get pods --namespace [TEAM]-dockerimage
NAME                                 READY   STATUS    RESTARTS   AGE
appuio-php-docker-86d9d584f8-7vjcj   1/1     Running   0          5m2s
appuio-php-docker-86d9d584f8-hbvlv   1/1     Running   0          31s
appuio-php-docker-86d9d584f8-qg499   1/1     Running   0          31s

```

**Tip:** Kubernetes even supports [autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).


## Check for Uninterruptible Scaling/Deploying

Now we create a new service with type NodePort:

```
$ kubectl expose deployment appuio-php-docker --type="NodePort" --name="appuio-php-docker" --port=80 --target-port=8080 --namespace [TEAM]-dockerimage
```

Let's look at our service. We should see all three endpoints referenced:

```bash
$ kubectl describe service appuio-php-docker --namespace [TEAM]-dockerimage
Name:                     appuio-php-docker
Namespace:                philipona-scale
Labels:                   app=appuio-php-docker
Annotations:              <none>
Selector:                 app=appuio-php-docker
Type:                     LoadBalancer
IP:                       10.39.245.205
Port:                     <unset>  80/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  32193/TCP
Endpoints:                10.36.0.10:8080,10.36.0.11:8080,10.36.0.9:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  2s    service-controller  Ensuring load balancer
```

Scaling of pods within a service ist fast, as Kubernetes simply creates a new container


**Tip:** Kubernetes even supports [autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

You can check the availability of your service while you scale the number of replicas up and down.
Replace the `URL` placeholder with the actual, constructed URL:

```
NodePort=32193

URL=http://[NodeIP]:38709/
```

**Tip:** Check previous lab on how to get the `NodeIP`

Now, execute the corresponding loop command for your operating system.


```
@Linux:
while true; do sleep 1; curl -s [URL]/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

```
@Windows (ab Powershell-Version 3.0):
while(1) { 
	Start-Sleep -s 1 
	Invoke-RestMethod http://[URL]/pod/ 
	Get-Date -Uformat "+ TIME: %H:%M:%S,%3N" 
}
```

and scale from **3** to **1** replicas.
The output shows which pod responded to the sent request:


```
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:07,289
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:08,357
POD: appuio-php-docker-86d9d584f8-hbvlv TIME: 17:33:09,423
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:10,494
POD: appuio-php-docker-86d9d584f8-qg499 TIME: 17:33:11,559
POD: appuio-php-docker-86d9d584f8-hbvlv TIME: 17:33:12,629
POD: appuio-php-docker-86d9d584f8-qg499 TIME: 17:33:13,695
POD: appuio-php-docker-86d9d584f8-hbvlv TIME: 17:33:14,771
POD: appuio-php-docker-86d9d584f8-hbvlv TIME: 17:33:15,840
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:16,912
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:17,980
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:19,051
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:20,119
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:21,182
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:22,248
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:23,313
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:24,377
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:25,445
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:33:26,513
```
The requests are being distributed amongst the pods. As soon as you scale down to one pod, there should only be one pod remaining that responds.

But what happens if start a new deployment while our while command is running?


**Tip:** If on Windows, execute the following command in Gitbash, Powershell seems not to work.

```
$ kubectl patch deployment appuio-php-docker -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}" --namespace [TEAM]-dockerimage
```
During a short period we won't get a response:
```
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:24,121
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:25,189
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:26,262
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:27,328
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:28,395
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:29,459
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:30,531
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:31,596
POD: appuio-php-docker-86d9d584f8-7vjcj TIME: 17:37:32,662
# no answer
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:33,729
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:34,794
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:35,862
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:36,929
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:37,995
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:39,060
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:40,118
POD: appuio-php-docker-f4c5dd8fc-4nx2t TIME: 17:37:41,187
```

In our example we use a very lightweight pod. If we had used a more heavy-weight pod that needed a longer time to respond to requests, we would of course see a larger gap.
An example for this would be the Java application from [lab 4](04_deploy_dockerimage.md): **Startup time: 30 seconds**:


```
Pod: example-spring-boot-2-73aln TIME: 16:48:25,251
Pod: example-spring-boot-2-73aln TIME: 16:48:26,305
Pod: example-spring-boot-2-73aln TIME: 16:48:27,400
Pod: example-spring-boot-2-73aln TIME: 16:48:28,463
Pod: example-spring-boot-2-73aln TIME: 16:48:29,507
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:33,562
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:34,601
 ...
Pod: example-spring-boot-3-tjdkj TIME: 16:49:20,114
Pod: example-spring-boot-3-tjdkj TIME: 16:49:21,181
Pod: example-spring-boot-3-tjdkj TIME: 16:49:22,231

```

It is even possible that the service gets down and the routing layer responds with the status code 503 as can be seen in the example output above.

In the following chapter we are going to look at how a service can be configured to be highly available.


## Uninterruptable Deployments

The [rolling](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/) update strategy makes it possible to deploy pods without interruption. The rolling update strategy means that the new version of an application gets deployed and started. As soon as the application says it is ready, Kubernetes forwards requests to the new instead of the old version of the pod and the old pod is terminated.

Additionally, [container health checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/) help Kubernetes to precisely determine what state the application is in.

Basically there are two different kinds of checks that can be implemented:

- Liveness probes are used to find out if an application is still running
- Readiness probes tell us if the application es ready to receive requests (which is especially relevant for above-mentioned rolling updates)

These probes can be implemented as HTTP checks, container execution checks (the execution of a command or script inside a container) or TCP socket checks.

In our example we want the application to tell Kubernetes that it is ready for requests with an appropriate readiness probe. Our example application has a health check endpoint on port 8080 at:

```
http://[URL]:8080/health/
```


## Task: LAB6.3

In our deployment configuration inside the rolling update strategy section we define that our application has to be always be available during an update: `maxUnavailable: 0%`

You can directly edit the deployment (or any resource) with:

```
$ kubectl edit deployment appuio-php-docker --namespace [TEAM]-dockerimage
```


**YAML:**
```
...
spec:
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 0%
    type: RollingUpdate
...
```


If you prefer json formatting to yaml, use the `--output`/`-o` parameter to edit the resource in json:
```
$ kubectl edit deployment appuio-php-docker -o json --namespace [TEAM]-dockerimage
```
**json**
```
"strategy": {
    "rollingUpdate": {
        "maxSurge": "25%",
        "maxUnavailable": "0%"
    },
    "type": "RollingUpdate"
},

```

Now insert the readiness probe at `.spec.template.spec.containers` above the `resources: { }` line:

**YAML:**

```bash
...
        readinessProbe:
          httpGet:
            path: /health/
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 10
          timeoutSeconds: 1
        resources: {  }
...
```

**json:**

```bash
...
                        "resources": {},
                        "readinessProbe": {
                            "httpGet": {
                                "path": "/health/",
                                "port": 8080,
                                "scheme": "HTTP"
                            },
                            "initialDelaySeconds": 10,
                            "periodSeconds": 10,
                            "timeoutSeconds": 1
                        },

...
```


The `containers` configuration then looks like:
**YAML:**

```bash
      containers:
      - image: appuio/example-php-docker-helloworld
        imagePullPolicy: Always
        name: example-php-docker-helloworld
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /health/
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File

```

**json:**

```bash
                "containers": [
                    {
                        "image": "appuio/example-php-docker-helloworld",
                        "imagePullPolicy": "Always",
                        "name": "example-php-docker-helloworld",
                        "readinessProbe": {
                            "failureThreshold": 3,
                            "httpGet": {
                                "path": "/health/",
                                "port": 8080,
                                "scheme": "HTTP"
                            },
                            "initialDelaySeconds": 10,
                            "periodSeconds": 10,
                            "successThreshold": 1,
                            "timeoutSeconds": 1
                        },
                        "resources": {},
                        "terminationMessagePath": "/dev/termination-log",
                        "terminationMessagePolicy": "File"
                    }
                ],
```

We are now going to verify that a redeployment of the application does not lead to an interruption:

Set up the loop to periodically check the application's response:

```bash
while true; do sleep 1; curl -s [URL]pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

Start a new deployment by editing it (the so-called ConfigChange trigger triggers the new deployment automatically):

```bash
$ kubectl patch deployment appuio-php-docker -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}" --namespace [TEAM]-dockerimage
```


## Self Healing

Via replicaset we told Kubernetes how many replicas we want. So what happens if we simply delete a pod?

Look for a running pod (status `RUNNING`) that you can bear to kill via `kubectl get pods`.

Show all pods and watch for changes:

```
kubectl get pods -w --namespace [TEAM]-dockerimage
```
Now delete a pod (in another terminal) with the following command:
```
kubectl delete pod appuio-php-docker-3-788j5 --namespace [TEAM]-dockerimage
```


Observe how Kubernetes instantly creates a new pod in order to fulfill the desired number of running replicas.


---

**End of lab 6**
