---
title: "10.6 Init container"
weight: 106
sectionnumber: 10.6
---


A Pod can have multiple containers running apps within it, but it can also have one or more *init containers*, which are run before the app containers are started.

Init containers are exactly like regular containers, except:

* Init containers always run to completion.
* Each init container must complete successfully before the next one starts.
  
Check [Init Container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) from the Kubernetes documentation for more details.


## Task {{% param sectionnumber %}}.1: Add init Container to our example-web-python application

In [lab 8](../../08.0/) you created the `example-web-python` application. In this task, you are going to add an init container which checks if the MySQL database is ready to be used before actually starting your python application.

Edit your existing `example-web-python` deployment with:

```bash
kubectl edit deployment example-web-python --namespace <namespace>
```

Add the init container into the existing Deployment:
{{< onlyWhenNot mobi >}}

```yaml
...
spec:
  initContainers:
  - name: wait-for-db
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mysql.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
...
```

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

```yaml
...
spec:
  initContainers:
  - name: wait-for-db
    image: docker-registry.mobicorp.ch/cop/curl-and-provide:latest
    command: ['sh', '-c', "until nslookup mysql.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
...
```

{{< /onlyWhen >}}
{{% alert title="Note" color="primary" %}}
This obviously only checks if there is a DNS Record for your MySQL Service and not if the database is ready. But you get the idea, right?
{{% /alert %}}

Let's see what has changed by analyzing your `example-web-python` Pod with the following command (use `kubectl get pod` or auto-completion to get the Pod name):

```bash
kubectl describe pod <pod> --namespace <namespace>
```

You see the new init container with the name `wait-for-db`:

```
...
Init Containers:
  wait-for-db:
    Container ID:  docker://77e6e309c88cfe62d03ed97e8fae20704bbf547a1e717a8f699ba79d9879cca2
    Image:         busybox:1.28
    Image ID:      docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until nslookup mysql.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Sun, 10 May 2020 13:00:14 +0200
      Finished:     Sun, 10 May 2020 13:00:14 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-xz2b7 (ro)
...
```

The init container has `State: Terminated` and an `Exit Code: 0` which means it was successful. That's what we wanted, the init container was successfully executed before our main application.

You can also check the logs of the init container with:

```bash
kubectl logs -c wait-for-db <pod> --namespace <namespace>
```

Which should give you something similar to (the `nslookup` output from the command in the init container):

```
Server:    10.43.0.10
Address 1: 10.43.0.10 kube-dns.kube-system.svc.cluster.local

Name:      mysql.spl.svc.cluster.local
Address 1: 10.43.243.105 mysql.spl.svc.cluster.local
```
