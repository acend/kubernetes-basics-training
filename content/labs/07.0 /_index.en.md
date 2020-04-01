---
title: "7.0 - Troubleshooting, what is a Pod?"
weight: 70
---

# Lab 7: Troubleshooting, what is a Pod?

This Lab helps you to troubleshoot your application and shows you some tools to make troubleshooting easier.

## Login to a Container

Running container should be treated as immutable infrastructure and should therefore not be modified. Although, there are some use-cases in which you have to login into your running container. Debugging and analyze is one example for this.


## Task: LAB7.1 Shell into POD


With Kubernetes you can open a remote Shell into a pod without installing SSH by Using the command `kubectl exec`. The command is used to executed anything in a pod. With the parameter `-it` you can leave open an connection. We can use `winpty` for this.

Choose a pod with `kubectl get pods --namespace [TEAM]-dockerimage` and execute the following command:

```bash
$ kubectl exec -it [POD] --namespace [TEAM]-dockerimage -- /bin/bash
```

With this, you can work inside the pod, e.g.:

```sh
/ $ ls -l
total 60
drwxr-xr-x    2 root     root          4096 Jan 16 21:52 bin
drwxr-xr-x    5 root     root           360 Apr  1 11:37 dev
drwxr-xr-x    1 root     root          4096 Apr  1 11:37 etc
drwxr-xr-x    1 root     root          4096 Mar 27 12:32 home
drwxr-xr-x    5 root     root          4096 Jan 16 21:52 lib
drwxr-xr-x    5 root     root          4096 Jan 16 21:52 media
drwxr-xr-x    2 root     root          4096 Jan 16 21:52 mnt
drwxr-xr-x    2 root     root          4096 Jan 16 21:52 opt
...
```

With `exit` you can leave the pod and close the connection

```sh
/ $ exit
```

## Task: LAB7.2 Single Command

Single commands inside a container can be executed with `kubectl exec`:


```bash
$ kubectl exec [POD] --namespace [TEAM]-dockerimage env
```

```bash
$ kubectl exec example-web-python-69b658f647-xnm94 --namespace [TEAM]-dockerimage env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=example-web-python-xnm94
KUBERNETES_SERVICE_PORT_DNS_TCP=53
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=172.30.0.1
KUBERNETES_PORT_53_UDP_PROTO=udp
KUBERNETES_PORT_53_TCP=tcp://172.30.0.1:53
...
```

## Watch Logfiles

Logfiles of a pod can with shown with the following command:


```bash
$ kubectl logs [POD] --namespace [TEAM]-dockerimage
```

The parameter `-f` allows you to follow the logfile (same as `tail -f`). With this, logfiles are streamed and new entries are shown directly

When a pod is in State **CrashLoopBackOff** it means, that even after some restarts, the pod could not be started successfully. Even if the pod is not running, logfiles can be viewed with the following command:


 ```bash
$ kubectl logs -p [POD] --namespace [TEAM]-dockerimage
```


## Task: LAB7.3 Port Forwarding

Kubernetes allows you to forward arbitrary ports to your development workstation. This allows you to access admin consoles, databases etc, even when they are not exposed externaly. Port forwarding are handled by the Kubernetes master and therefore tunneled from the client via HTTPS. This allows you to access the Kubernetes platform even when there are restrictive firewalls and/or proxies between your workstation and Kubernetes.

```bash
$ kubectl get pod --namespace [TEAM]-dockerimage
$ kubectl port-forward example-web-python-1-xj1df 5000:5000 --namespace [TEAM]-dockerimage
Forwarding from 127.0.0.1:5000 -> 5000
Forwarding from [::1]:5000 -> 5000
```

Don't forget to change the pod Name to your own Installation. If configured, you can use Auto-Completion.

The application is now available with the following Link: [localhost:5000/](http://localhost:5000/).
With the same concept you can access databases from your local client or connect your local development environment via remote debugging to your application in the pod.

With the following link you find more information about port forwarding: <https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/>

**Note:** The `kubectl port-forward`-process runs as long as it is not terminated by the user. So when done, stop it with CTRL-C.

---

**End Lab 7**
