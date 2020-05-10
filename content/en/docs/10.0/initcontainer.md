---
title: "10.6 Init Container"
weight: 106
---


A Pod can have multiple containers running apps within it, but it can also have one or more init containers, which are run before the app containers are started.

Init containers are exactly like regular containers, except:

* Init containers always run to completion.
* Each init container must complete successfully before the next one starts.
  
Check [Init Container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) from the Kubernetes docuemtation for more details

## Task: Add init Container to our example-web-python application

We are going to use our example-web-python application from [Lab 8](../08.0/) and add an init container which checks if the MySQL Database is ready to be used.

Edit your existing `example-web-pyhton` deployment with:

```bash
kubectl edit deplyoment example-web-python --namespace [NAMESPACE
```

and add the initContainer into the existing deployment:

```yaml
[...]
spec:
  initContainers:
  - name: wait-for-db
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mysql.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
[...]
```

{{% alert title="Note" color="warning" %}}
This obviusly only checks if there is an DNS Record for your mysql service and not if the database is ready. But you get the idea, right?
{{% /alert %}}


With (use `kubectl get pod` or autocompletion to get the pod name):

```bash
kubectl describe pod [POD NAME] --namespace [NAMESPACE]
```

you can see the new init container

```
[...]
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
[...]
```

As you cee, the initcontainer has `State: Terminate`d and an `Exit Code` of 0 which means it was successful.

You can also check the logs of the Init Container with:

```bash
kubectl logs -c wait-for-db  example-web-python-6b5d4ddb8f-94k2h
```

which should give sou something similar to (the nslookup output from the command in the initcontainer)

```
Server:    10.43.0.10
Address 1: 10.43.0.10 kube-dns.kube-system.svc.cluster.local

Name:      mysql.spl.svc.cluster.local
Address 1: 10.43.243.105 mysql.spl.svc.cluster.local
```
