---
title: "Troubleshooting"
weight: 6
---

This lab helps you troubleshoot your application and shows you some tools to make troubleshooting easier.


## Logging into a container

Running containers should be treated as immutable infrastructure and should therefore not be modified. However, there are some use cases in which you have to log into your running container. Debugging and analyzing is one example for this.


## {{% task %}} Shell into Pod

With {{% param distroName %}} you can open a remote shell into a Pod without installing SSH by using the command `{{% onlyWhenNot openshift %}}kubectl exec{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}oc rsh{{% /onlyWhen %}}`. The command can also be used to execute any command in a Pod.
{{% onlyWhenNot openshift %}}With the parameter `-it` you can leave an open connection.{{% /onlyWhenNot %}}

{{% alert title="Note" color="info" %}}
On Windows, you can use Git Bash and `winpty`.
{{% /alert %}}

Choose a Pod with `{{% param cliToolName %}} get pods --namespace <namespace>` and execute the following command:
{{% onlyWhenNot openshift %}}
```bash
kubectl exec -it <pod> --namespace <namespace> -- /bin/bash
```
{{% /onlyWhenNot %}}

{{% onlyWhen openshift %}}
```bash
oc rsh --namespace <namespace> <pod>
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
{{% alert title="Note" color="info" %}}
If Bash is not available in the Pod you can fallback to `-- sh` instead of `-- /bin/bash`.
{{% /alert %}}
{{% /onlyWhenNot %}}

You now have a running shell session inside the container in which you can execute every binary available, e.g.:

```bash
ls -l
```

```
total 12
-rw-r--r--    1 10020700 root          8192 Nov 27 15:12 hellos.db
-rwxrwsr-x    1 web      root          2454 Oct  5 08:55 run.py
drwxrwsr-x    1 web      root            17 Oct  5 08:55 static
drwxrwsr-x    1 web      root            63 Oct  5 08:55 templates
```

With `exit` or `CTRL+d` you can leave the container and close the connection:

```bash
exit
```


## {{% task %}} Single commands

{{% onlyWhenNot openshift %}}
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
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Single commands inside a container can also be executed with `oc rsh`:

```bash
oc rsh --namespace <namespace> <pod> <command>
```

Example:

```
oc rsh --namespace acend-test example-web-python-8b465c687-t9g7b env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TERM=xterm
HOSTNAME=example-web-python-8b465c687-t9g7b
NSS_SDB_USE_CACHE=no
KUBERNETES_PORT_443_TCP=tcp://172.30.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
EXAMPLE_WEB_PYTHON_PORT_5000_TCP_PORT=5000
...
```


## The debug command

One of the disadvantages of using the `oc rsh` command is that it depends on the container to actually run. If the Pod can't even start, this is a problem but also where the `oc debug` command comes in.
The `oc debug` command starts an interactive shell using the definition of a Deployment, Pod, DaemonSet, Job or even an ImageStreamTag. In OpenShift 4 it can also be used to open a shell on a Node to analyze it.

The quick way of using it is `oc debug RESOURCE/NAME` but have a good look at its help page. There are some very interesting parameters like `--as-root` that give you (depending on your permissions on the cluster) a very powerful means of debugging a Pod.
{{% /onlyWhen %}}


## Watching log files

Log files of a Pod can be shown with the following command:


```bash
{{% param cliToolName %}} logs <pod> --namespace <namespace>
```

The parameter `-f` allows you to follow the log file (same as `tail -f`). With this, log files are streamed and new entries are shown immediately.

When a Pod is in state `CrashLoopBackOff` it means that although multiple attempts have been made, no container inside the Pod could be started successfully. Now even though no container might be running at the moment the `{{% param cliToolName %}} logs` command is executed, there is a way to view the logs the application might have generated. This is achieved using the `-p` or `--previous` parameter:

 ```bash
{{% param cliToolName %}} logs -p <pod> --namespace <namespace>
```


## {{% task %}} Port forwarding

{{% param distroName %}} allows you to forward arbitrary ports to your development workstation. This allows you to access admin consoles, databases, etc., even when they are not exposed externally. Port forwarding is handled by the {{% param distroName %}} master and therefore tunneled from the client via HTTPS. This allows you to access the {{% param distroName %}} platform even when there are restrictive firewalls or proxies between your workstation and {{% param distroName %}}.

Get the name of the Pod:

```bash
{{% param cliToolName %}} get pod --namespace <namespace>
```

Then execute the port forwarding command using the Pod's name:

```bash
{{% param cliToolName %}} port-forward <pod> 5000:5000 --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
Use the additional parameter `--address <IP address>` (where `<IP address>` refers to a NIC's IP address from your local workstation) if you want to access the forwarded port from outside your own local workstation.
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

With the same concept you can access databases from your local workstation or connect your local development environment via remote debugging to your application in the Pod.

{{% onlyWhenNot openshift %}}[This documentation page](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster){{% /onlyWhenNot %}}{{% onlyWhen openshift %}}[This documentation page](https://docs.openshift.com/container-platform/latest/nodes/containers/nodes-containers-port-forwarding.html){{% /onlyWhen %}} offers some more details about port forwarding.

{{% alert title="Note" color="info" %}}
The `{{% param cliToolName %}} port-forward` process runs as long as it is not terminated by the user. So when done, stop it with `CTRL-c`.
{{% /alert %}}


## Progress

At this point, you are able to visualize your progress on the labs by browsing through the following page <http://localhost:5000/progress>

If you are not able to open your awesome-app with localhost, because you are using a webshell, you can also use the ingress address like: `example-web-python-<namespace>.<domain>/progress` to access the dashboard.

You may need to set some extra permissions to let the dashboard monitor your progress. Have fun!

```bash
{{% param cliToolName %}} create rolebinding progress --clusterrole=view --serviceaccount=<namespace>:default --namespace=<namespace>
```


## Events

{{% param distroName %}} maintains an event log with high-level information on what's going on in the cluster.
It's possible that everything looks okay at first but somehow something seems stuck.
Make sure to have a look at the events because they can give you more information if something is not working as expected.

Use the following command to list the events in chronological order:

```bash
{{% param cliToolName %}} get events --sort-by=.metadata.creationTimestamp --namespace <namespace>
```


## Dry-run

To help verify changes, you can use the optional `{{% param cliToolName %}}` flag `--dry-run=client -o yaml` to see the rendered YAML definition of your Kubernetes objects, without sending it to the API.

The following `{{% param cliToolName %}}` subcommands support this flag (non-final list):

* `apply`
* `create`
* `expose`
* `patch`
* `replace`
* `run`
* `set`

For example, we can use the `--dry-run=client` flag to create a template for our Deployment:

```bash
{{% param cliToolName %}} create deployment example-web-go --image=quay.io/acend/example-web-go:latest --namespace acend-test --dry-run=client -o yaml
```

The result is the following YAML output:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: example-web-go
  name: example-web-go
  namespace: acend-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: example-web-go
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: example-web-go
    spec:
      containers:
      - image: quay.io/acend/example-web-go:latest
        name: example-web-go
        resources: {}
status: {}
```


## See the API requests of `{{% param cliToolName %}}`

If you want to see the HTTPS requests to the Kubernetes API in detail, you can use the optional `{{% param cliToolName %}}` flag `--v=10`.

For example, to see the API request for creating a namespace:

```bash
{{% param cliToolName %}} create namespace acend-test --v=10
```

The resulting output looks like this:

```bash
I1109 16:42:21.438803  268345 request.go:1073] Request Body: {"kind":"Namespace","apiVersion":"v1","metadata":{"name":"acend-test","creationTimestamp":null},"spec":{},"status":{}}
I1109 16:42:21.438862  268345 round_trippers.go:466] curl -v -XPOST  -H "Accept: application/json, */*" -H "Content-Type: application/json" -H "User-Agent: oc/4.11.0 (linux/amd64) kubernetes/7075089" -H "Authorization: Bearer <masked>" 'https://api.training.openshift.ch:6443/api/v1/namespaces?fieldManager=kubectl-create&fieldValidation=Ignore'
I1109 16:42:21.468590  268345 round_trippers.go:495] HTTP Trace: DNS Lookup for api.training.openshift.ch resolved to [{16.170.14.174 } {13.53.141.154 } {13.49.184.94 }]
I1109 16:42:21.520614  268345 round_trippers.go:510] HTTP Trace: Dial to tcp:16.170.14.174:6443 succeed
I1109 16:42:21.705733  268345 round_trippers.go:553] POST https://api.training.openshift.ch:6443/api/v1/namespaces?fieldManager=kubectl-create&fieldValidation=Ignore 201 Created in 266 milliseconds
I1109 16:42:21.705849  268345 round_trippers.go:570] HTTP Statistics: DNSLookup 29 ms Dial 51 ms TLSHandshake 103 ms ServerProcessing 81 ms Duration 266 ms
I1109 16:42:21.705900  268345 round_trippers.go:577] Response Headers:
I1109 16:42:21.705955  268345 round_trippers.go:580]     Audit-Id: dd52d6eb-5479-4960-9367-09f5571dd779
I1109 16:42:21.705999  268345 round_trippers.go:580]     Cache-Control: no-cache, private
I1109 16:42:21.706049  268345 round_trippers.go:580]     Content-Type: application/json
I1109 16:42:21.706154  268345 round_trippers.go:580]     X-Kubernetes-Pf-Flowschema-Uid: 950aa9cf-a0c2-4b42-943b-41b1b73921bf
I1109 16:42:21.706216  268345 round_trippers.go:580]     X-Kubernetes-Pf-Prioritylevel-Uid: ff295cbf-f8c0-4327-9ec6-625f04de293d
I1109 16:42:21.706277  268345 round_trippers.go:580]     Content-Length: 530
I1109 16:42:21.706336  268345 round_trippers.go:580]     Date: Wed, 09 Nov 2022 15:42:21 GMT
I1109 16:42:21.706527  268345 request.go:1073] Response Body: {"kind":"Namespace","apiVersion":"v1","metadata":{"name":"acend-test","uid":"19edb3ff-0beb-4c72-a2bb-297c5bde08c5","resourceVersion":"8783080","creationTimestamp":"2022-11-09T15:42:21Z","labels":{"kubernetes.io/metadata.name":"acend-test"},"managedFields":[{"manager":"kubectl-create","operation":"Update","apiVersion":"v1","time":"2022-11-09T15:42:21Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:kubernetes.io/metadata.name":{}}}}}]},"spec":{"finalizers":["kubernetes"]},"status":{"phase":"Active"}}
namespace/acend-test created
```

As you can see, the output conveniently contains the corresponding `curl` commands which we could use in our own code, tools, pipelines etc.

