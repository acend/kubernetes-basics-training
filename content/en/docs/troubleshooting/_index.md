---
title: "Troubleshooting"
weight: 6
---

This lab helps you troubleshoot your application and shows you some tools to make troubleshooting easier.


## Logging into a container

Running containers should be treated as immutable infrastructure and should therefore not be modified. However, there are some use cases in which you have to log into your running container. Debugging and analyzing is one example for this.


## {{% task %}} Shell into Pod

With {{% param distroName %}} you can open a remote shell into a Pod without installing SSH by using the command `{{% param cliToolName %}} {{% onlyWhenNot openshift %}}exec{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}rsh{{% /onlyWhen %}}`. The command can also be used to execute any command in a Pod.
{{% onlyWhenNot openshift %}}If you want to get a shell to a running container, you will additionally need the parameters `-it`. These set up an interactive session where you can supply input to the process inside the container.{{% /onlyWhenNot %}}

{{% alert title="Note" color="info" %}}
If you're using Git Bash on Windows, you need to append the command with `winpty`.
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

{{% onlyWhenNot sbb %}}

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

{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}

```bash
pwd
```

```
/home/default
```

With `exit` or `CTRL+d` you can leave the container and close the connection:

```bash
exit
```

{{% /onlyWhen %}}


## {{% task %}} Single commands

{{% onlyWhenNot openshift %}}
Single commands inside a container can also be executed with `kubectl exec`:

```bash
kubectl exec <pod> --namespace <namespace> -- env
```

Example:

```bash
$ kubectl exec example-web-app-69b658f647-xnm94 --namespace <namespace> -- env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=example-web-app-xnm94
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
oc rsh --namespace acend-test example-web-app-8b465c687-t9g7b env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TERM=xterm
HOSTNAME=example-web-app-8b465c687-t9g7b
NSS_SDB_USE_CACHE=no
KUBERNETES_PORT_443_TCP=tcp://172.30.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
EXAMPLE_WEB_APP_PORT_5000_TCP_PORT=5000
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

When a Pod is in state `CrashLoopBackOff` it means that although multiple attempts have been made, no container inside the Pod could be started successfully. Now even though no container might be running at the moment the `{{% param cliToolName %}} logs` command is executed, there is a way to view the logs the application might have generated. This is achieved using the `-p` or `--previous` parameter.

{{% alert title="Note" color="info" %}}
This command will only work on pods that had container restarts. You can check the `RESTARTS` column in the `{{% param cliToolName %}} get pods` output if this is the case.
{{% /alert %}}

```bash
{{% param cliToolName %}} logs -p <pod> --namespace <namespace>
```

{{% onlyWhen baloise %}}
{{% alert title="Note" color="info" %}}
Baloise uses [Splunk](https://www.splunk.com/) to aggregate and visualize all logs, including those of Pods.
{{% /alert %}}
{{% /onlyWhen %}}


## {{% task %}} Port forwarding

{{% param distroName %}} allows you to forward arbitrary ports to your development workstation. This allows you to access admin consoles, databases, etc., even when they are not exposed externally. Port forwarding is handled by the {{% param distroName %}} control plane nodes and therefore tunneled from the client via HTTPS. This allows you to access the {{% param distroName %}} platform even when there are restrictive firewalls or proxies between your workstation and {{% param distroName %}}.

Get the name of the Pod:

```bash
{{% param cliToolName %}} get pod --namespace <namespace>
```

Then execute the port forwarding command using the Pod's name:

{{% alert title="Note" color="info" %}}
Best run this command in a separate shell, or in the background by adding a "&" at the end of the command.
{{% /alert %}}

{{% onlyWhenNot sbb %}}

```bash
{{% param cliToolName %}} port-forward <pod> 5000:5000 --namespace <namespace>
```

Don't forget to change the Pod name to your own installation. If configured, you can use auto-completion.

The output of the command should look like this:

```
Forwarding from 127.0.0.1:5000 -> 5000
Forwarding from [::1]:5000 -> 5000
```

{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}

```bash
{{% param cliToolName %}} port-forward <pod> {{% param "containerImages.training-image-probe-port" %}}:{{% param "containerImages.training-image-probe-port" %}} --namespace <namespace>
```

Don't forget to change the Pod name to your own installation. If configured, you can use auto-completion.

The output of the command should look like this:

```
Forwarding from 127.0.0.1:{{% param "containerImages.training-image-probe-port" %}} -> {{% param "containerImages.training-image-probe-port" %}}
Forwarding from [::1]:{{% param "containerImages.training-image-probe-port" %}} -> {{% param "containerImages.training-image-probe-port" %}}
```

{{% /onlyWhen %}}

{{% alert title="Note" color="info" %}}
Use the additional parameter `--address <IP address>` (where `<IP address>` refers to a NIC's IP address from your local workstation) if you want to access the forwarded port from outside your own local workstation.
{{% /alert %}}

{{% onlyWhenNot sbb %}}
The application is now available with the following link: <http://localhost:5000/>. Or try a `curl` command:

```bash
curl localhost:5000
```

{{% /onlyWhenNot %}}
{{% onlyWhen sbb %}}
Now the health endpoint is available at: <http://localhost:{{% param "containerImages.training-image-probe-port" %}}/>.

We could not access this endpoint before because it is only exposed inside the cluster.

The application probe endpoint is now available with the following link: <http://localhost:{{% param "containerImages.training-image-probe-port" %}}/health>. Or try a `curl` command:

```bash
curl localhost:{{% param "containerImages.training-image-probe-port" %}}/health
```

{{% /onlyWhen %}}

With the same concept you can access databases from your local workstation or connect your local development environment via remote debugging to your application in the Pod.

{{% onlyWhenNot openshift %}}[This documentation page](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster){{% /onlyWhenNot %}}{{% onlyWhen openshift %}}[This documentation page](https://docs.openshift.com/container-platform/latest/nodes/containers/nodes-containers-port-forwarding.html){{% /onlyWhen %}} offers some more details about port forwarding.

{{% alert title="Note" color="info" %}}
The `{{% param cliToolName %}} port-forward` process runs as long as it is not terminated by the user. So when done, stop it with `CTRL-c`.
{{% /alert %}}


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
{{% param cliToolName %}} create deployment example-web-app --image={{% param "containerImages.training-image-url" %}} --namespace acend-test --dry-run=client -o yaml
```

The result is the following YAML output:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: example-web-app
  name: example-web-app
  namespace: acend-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: example-web-app
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: example-web-app
    spec:
      containers:
        - image: {{% param "containerImages.training-image-url" %}}
          name: example-web
          resources: {}
status: {}
```


## `{{% param cliToolName %}}` API requests

If you want to see the HTTP requests `{{% param cliToolName %}}` sends to the Kubernetes API in detail, you can use the optional flag `--v=10`.

For example, to see the API request for creating a deployment:

```bash
{{% param cliToolName %}} create deployment test-deployment --image={{% param "containerImages.training-image-url" %}} --namespace <namespace> --replicas=0 --v=10
```

The resulting output looks like this:

```bash
I1114 15:31:13.605759   85289 request.go:1073] Request Body: {"kind":"Deployment","apiVersion":"apps/v1","metadata":{"name":"test-deployment","namespace":"acend-test","creationTimestamp":null,"labels":{"app":"test-deployment"}},"spec":{"replicas":0,"selector":{"matchLabels":{"app":"test-deployment"}},"template":{"metadata":{"creationTimestamp":null,"labels":{"app":"test-deployment"}},"spec":{"containers":[{"name":"example-web","image":"{{% param "containerImages.training-image-url" %}}","resources":{}}]}},"strategy":{}},"status":{}}
I1114 15:31:13.605817   85289 round_trippers.go:466] curl -v -XPOST  -H "Accept: application/json, */*" -H "Content-Type: application/json" -H "User-Agent: oc/4.11.0 (linux/amd64) kubernetes/262ac9c" -H "Authorization: Bearer <masked>" 'https://api.ocp-staging.cloudscale.puzzle.ch:6443/apis/apps/v1/namespaces/acend-test/deployments?fieldManager=kubectl-create&fieldValidation=Ignore'
I1114 15:31:13.607320   85289 round_trippers.go:495] HTTP Trace: DNS Lookup for api.ocp-staging.cloudscale.puzzle.ch resolved to [{5.102.150.82 }]
I1114 15:31:13.611279   85289 round_trippers.go:510] HTTP Trace: Dial to tcp:5.102.150.82:6443 succeed
I1114 15:31:13.675096   85289 round_trippers.go:553] POST https://api.ocp-staging.cloudscale.puzzle.ch:6443/apis/apps/v1/namespaces/acend-test/deployments?fieldManager=kubectl-create&fieldValidation=Ignore 201 Created in 69 milliseconds
I1114 15:31:13.675120   85289 round_trippers.go:570] HTTP Statistics: DNSLookup 1 ms Dial 3 ms TLSHandshake 35 ms ServerProcessing 27 ms Duration 69 ms
I1114 15:31:13.675137   85289 round_trippers.go:577] Response Headers:
I1114 15:31:13.675151   85289 round_trippers.go:580]     Audit-Id: 509255b1-ee23-479a-be56-dfc3ab073864
I1114 15:31:13.675164   85289 round_trippers.go:580]     Cache-Control: no-cache, private
I1114 15:31:13.675181   85289 round_trippers.go:580]     Content-Type: application/json
I1114 15:31:13.675200   85289 round_trippers.go:580]     X-Kubernetes-Pf-Flowschema-Uid: e3e152ee-768c-43c5-b350-bb3cbf806147
I1114 15:31:13.675215   85289 round_trippers.go:580]     X-Kubernetes-Pf-Prioritylevel-Uid: 47f392da-68d1-4e43-9d77-ff5f7b7ecd2e
I1114 15:31:13.675230   85289 round_trippers.go:580]     Content-Length: 1739
I1114 15:31:13.675244   85289 round_trippers.go:580]     Date: Mon, 14 Nov 2022 14:31:13 GMT
I1114 15:31:13.676116   85289 request.go:1073] Response Body: {"kind":"Deployment","apiVersion":"apps/v1","metadata":{"name":"test-deployment","namespace":"acend-test","uid":"a6985d28-3caa-451f-a648-4c7cde3b51ac","resourceVersion":"2069385577","generation":1,"creationTimestamp":"2022-11-14T14:31:13Z","labels":{"app":"test-deployment"},"managedFields":[{"manager":"kubectl-create","operation":"Update","apiVersion":"apps/v1","time":"2022-11-14T14:31:13Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:app":{}}},"f:spec":{"f:progressDeadlineSeconds":{},"f:replicas":{},"f:revisionHistoryLimit":{},"f:selector":{},"f:strategy":{"f:rollingUpdate":{".":{},"f:maxSurge":{},"f:maxUnavailable":{}},"f:type":{}},"f:template":{"f:metadata":{"f:labels":{".":{},"f:app":{}}},"f:spec":{"f:containers":{"k:{\"name\":\"example-web\"}":{".":{},"f:image":{},"f:imagePullPolicy":{},"f:name":{},"f:resources":{},"f:terminationMessagePath":{},"f:terminationMessagePolicy":{}}},"f:dnsPolicy":{},"f:restartPolicy":{},"f:schedulerName":{},"f:securityContext":{},"f:terminationGracePeriodSeconds":{}}}}}}]},"spec":{"replicas":0,"selector":{"matchLabels":{"app":"test-deployment"}},"template":{"metadata":{"creationTimestamp":null,"labels":{"app":"test-deployment"}},"spec":{"containers":[{"name":"example-web","image":"{{% param "containerImages.training-image-url" %}}","resources":{},"terminationMessagePath":"/dev/termination-log","terminationMessagePolicy":"File","imagePullPolicy":"Always"}],"restartPolicy":"Always","terminationGracePeriodSeconds":30,"dnsPolicy":"ClusterFirst","securityContext":{},"schedulerName":"default-scheduler"}},"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxUnavailable":"25%","maxSurge":"25%"}},"revisionHistoryLimit":10,"progressDeadlineSeconds":600},"status":{}}
deployment.apps/test-deployment created
```

As you can see, the output conveniently contains the corresponding `curl` commands which we could use in our own code, tools, pipelines etc.

{{% alert title="Note" color="info" %}}
If you created the deployment to see the output, you can delete it again as it's not used anywhere else (which is also the reason why the replicas are set to `0`):

```bash
{{% param cliToolName %}} delete deploy/test-deployment --namespace <namespace>
```

{{% /alert %}}

{{% onlyWhenNot sbb %}}


## Progress

At this point, you are able to visualize your progress on the labs by browsing through the following page <http://localhost:5000/progress>

If you are not able to open your awesome-app with localhost, because you are using a webshell, you can also use the ingress address: `https://example-web-app-<namespace>.<appdomain>/progress` to access the dashboard.

You may need to set some extra permissions to let the dashboard monitor your progress. Have fun!

```bash
{{% param cliToolName %}} create rolebinding progress --clusterrole=view --serviceaccount=<namespace>:default --namespace=<namespace>
```
{{% /onlyWhenNot %}}
