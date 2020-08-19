---
title: "7. Troubleshooting"
weight: 7
sectionnumber: 7
---

This lab helps you troubleshoot your application and shows you some tools to make troubleshooting easier.


## Logging into a container

Running containers should be treated as immutable infrastructure and should therefore not be modified. However, there are some use cases in which you have to log into your running container. Debugging and analyzing is one example for this.


## Task {{% param sectionnumber %}}.1: Shell into Pod

With Kubernetes you can open a remote shell into a Pod without installing SSH by using the command `kubectl exec`. The command can be used to execute anything in a Pod. With the parameter `-it` you can leave an open connection.

{{% alert title="Note" color="primary" %}}
On Windows, you can use Git Bash and `winpty`.
{{% /alert %}}


Choose a Pod with `kubectl get pods --namespace <namespace>` and execute the following command:

```bash
kubectl exec -it <pod> --namespace <namespace> -- /bin/bash
```

{{% alert title="Note" color="primary" %}}
If Bash is not available in the Pod you can fallback to `-- sh` instead of `-- /bin/bash`.
{{% /alert %}}

With this, you can work inside the Pod:

```bash
ls -l
```

```
total 60
drwxr-xr-x    2 root     root          4096 Jan 16 21:52 bin
drwxr-xr-x    5 root     root           360 Apr  1 11:37 dev
drwxr-xr-x    1 root     root          4096 Apr  1 11:37 etc
drwxr-xr-x    1 root     root          4096 Mar 27 12:32 home
drwxr-xr-x    5 root     root          4096 Jan 16 21:52 lib
drwxr-xr-x    5 root     root          4096 Jan 16 21:52 media
drwxr-xr-x    2 root     root          4096 Jan 16 21:52 mnt
drwxr-xr-x    2 root     root          4096 Jan 16 21:52 opt

```

With `exit` you can leave the Pod and close the connection:

```sh
exit
```


## Task {{% param sectionnumber %}}.2: Single command

Single commands inside a container can also be executed with `kubectl exec`:

```bash
kubectl exec <pod> --namespace <namespace> -- env
```

Example:

```bash
$ kubectl exec example-web-python-69b658f647-xnm94 --namespace <namespace> -- env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=example-web-python-xnm94
KUBERNETES_SERVICE_PORT_DNS_TCP=53
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=172.30.0.1
KUBERNETES_PORT_53_UDP_PROTO=udp
KUBERNETES_PORT_53_TCP=tcp://172.30.0.1:53
...
```


## Watching log files

Log files of a Pod can be shown with the following command:


```bash
kubectl logs <pod> --namespace <namespace>
```

The parameter `-f` allows you to follow the log file (same as `tail -f`). With this, log files are streamed and new entries are shown immediately.

When a Pod is in state `CrashLoopBackOff` it means that even after some restarts the Pod could not be started successfully. Even if the Pod is not running, log files can be viewed with the following command:

 ```bash
kubectl logs -p <pod> --namespace <namespace>
```


## Task {{% param sectionnumber %}}.3: Port forwarding

Kubernetes allows you to forward arbitrary ports to your development workstation. This allows you to access admin consoles, databases, etc., even when they are not exposed externally. Port forwarding is handled by the Kubernetes master and therefore tunneled from the client via HTTPS. This allows you to access the Kubernetes platform even when there are restrictive firewalls and/or proxies between your workstation and Kubernetes.

Get the name of the Pod:

```bash
kubectl get pod --namespace <namespace>
```

Then execute the port forwarding with this name:

```bash
kubectl port-forward <pod> 5000:5000 --namespace <namespace>
```

{{% alert title="Note" color="primary" %}}
Use the additional parameter `--address 0.0.0.0` if you want to access the forwarded port from outside.  
{{% /alert %}}

The output of the command should look like this:

```
Forwarding from 127.0.0.1:5000 -> 5000
Forwarding from [::1]:5000 -> 5000
```

Don't forget to change the Pod name to your own installation. If configured, you can use auto-completion.

The application is now available with the following link: <http://localhost:5000/>. Or try a `curl` command:

```bash
curl localhost:5000
```

With the same concept you can access databases from your local client or connect your local development environment via remote debugging to your application in the Pod.

With the following link you find more information about port forwarding: <https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/>

{{% alert title="Note" color="primary" %}}
The `kubectl port-forward` process runs as long as it is not terminated by the user. So when done, stop it with `CTRL-c`.
{{% /alert %}}


## Events

Kubernetes maintains an event log with high-level information on what's going on in the cluster. 
It's possible that everything looks okay at first glance but somehow something seems stuck.
Make sure to have a look at the events because they can give you more information if something is not working as expected.

Use the following command to list the events in chronological order:

```bash
kubectl get events --sort-by=.metadata.creationTimestamp --namespace <namespace>
```
