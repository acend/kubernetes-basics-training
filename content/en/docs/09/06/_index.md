---
title: "9.6 Init containers"
weight: 96
sectionnumber: 9.6
---


A Pod can have multiple containers running apps within it, but it can also have one or more *init containers*, which are run before the app container is started.

Init containers are exactly like regular containers, except:

* Init containers always run to completion.
* Each init container must complete successfully before the next one starts.

{{% onlyWhenNot openshift %}}
Check [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) from the Kubernetes documentation for more details.
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Check out the [Init Containers documentation](https://docs.openshift.com/container-platform/latest/nodes/containers/nodes-containers-init.html) for more details.
{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.1: Add an init container

In [lab 7](../../07/) you created the `example-web-python` application. In this task, you are going to add an init container which checks if the MariaDB database is ready to be used before actually starting your Python application.

Edit your existing `example-web-python` Deployment with:

```bash
{{% param cliToolName %}} edit deployment example-web-python --namespace <namespace>
```

Add the init container into the existing Deployment:

```yaml
...
spec:
  initContainers:
  - name: wait-for-db
    image: {{% param registry_dockerio %}}busybox:1.28
    command: ['sh', '-c', "until nslookup mariadb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
...
```

{{% alert title="Note" color="primary" %}}
This obviously only checks if there is a DNS Record for your MariaDB Service and not if the database is ready. But you get the idea, right?
{{% /alert %}}

Let's see what has changed by analyzing your `example-web-python` Pod with the following command (use `{{% param cliToolName %}} get pod` or auto-completion to get the Pod name):

```bash
{{% param cliToolName %}} describe pod <pod> --namespace <namespace>
```

You see the new init container with the name `wait-for-db`:

```
...
Init Containers:
  wait-for-db:
    Container ID:  docker://77e6e309c88cfe62d03ed97e8fae20704bbf547a1e717a8f699ba79d9879cca2
    Image:         busybox
    Image ID:      docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until nslookup mariadb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Tue, 10 Nov 2020 21:00:24 +0100
      Finished:     Tue, 10 Nov 2020 21:02:52 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-xz2b7 (ro)
...
```

The init container has the `State: Terminated` and an `Exit Code: 0` which means it was successful. That's what we wanted, the init container was successfully executed before our main application.

You can also check the logs of the init container with:

```bash
{{% param cliToolName %}} logs -c wait-for-db <pod> --namespace <namespace>
```

Which should give you something similar to:

```
Server:    10.43.0.10
Address 1: 10.43.0.10 kube-dns.kube-system.svc.cluster.local

Name:      mariadb.acend-test.svc.cluster.local
Address 1: 10.43.243.105 mariadb.acend-test.svc.cluster.local
```

{{% onlyWhenNot openshift %}}
Check [Init Container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) from the Kubernetes documentation for more details.
{{% /onlyWhenNot %}}

{{% onlyWhen openshift %}}


## Deployment hooks on OpenShift

A similar concept are the so-called pre and post deployment hooks. Those hooks basically give the possibility to execute Pods before and after a deployment is in progress.

Check out the [official documentation](https://docs.openshift.com/container-platform/latest/applications/deployments/deployment-strategies.html) for further information.
{{% /onlyWhen %}}


## Save point

You should now have the following resources in place:

* {{% onlyWhenNot customer %}}[example-web-python.yaml](example-web-python.yaml){{% /onlyWhenNot %}}
  {{% onlyWhen customer %}}[example-web-python-{{% param customer %}}.yaml](example-web-python-{{% param customer %}}.yaml){{% /onlyWhen %}}
