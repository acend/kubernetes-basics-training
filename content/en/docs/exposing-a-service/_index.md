---
title: "Exposing a service"
weight: 4
---

In this lab, we are going to make the freshly deployed application from the last lab available online.


## {{% task %}} Create a ClusterIP Service

The command `{{% param cliToolName %}} apply -f 03_deployment.yaml` from the last lab creates a Deployment but no Service. A {{% param distroName %}} Service is an abstract way to expose an application running on a set of Pods as a network service. For some parts of your application (for example, frontends) you may want to expose a Service to an external IP address which is outside your cluster.

{{% param distroName %}} `ServiceTypes` allow you to specify what kind of Service you want. The default is `ClusterIP`.

`Type` values and their behaviors are:

* `ClusterIP`: Exposes the Service on a cluster-internal IP. Choosing this value only makes the Service reachable from within the cluster. This is the default ServiceType.

* `NodePort`: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service from outside the cluster, by requesting \<NodeIP\>:\<NodePort\>.

* `LoadBalancer`: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.

* `ExternalName`: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up.

You can also use Ingress to expose your Service. Ingress is not a Service type, but it acts as the entry point for your cluster. [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.
Traffic routing is controlled by rules defined on the {{% onlyWhenNot openshift %}}Ingress{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}Route{{% /onlyWhen %}} resource. {{% onlyWhenNot openshift %}}An Ingress{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}A Route{{% /onlyWhen %}} may be configured to give Services externally reachable URLs, load balance traffic, terminate SSL / TLS, and offer name-based virtual hosting. An Ingress controller is responsible for fulfilling the route, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

In order to create {{% onlyWhenNot openshift %}}an Ingress{{% /onlyWhenNot %}}{{% onlyWhen openshift %}}a Route{{% /onlyWhen %}}, we first need to create a Service of type [ClusterIP](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types).
We're going to do this with the command `{{% param cliToolName %}} expose`:

```bash
{{% param cliToolName %}} expose deployment example-web-go --type=ClusterIP --name=example-web-go --port=5000 --target-port=5000 --namespace <namespace>
```

{{% onlyWhen openshift %}}
You will get the error message reading `Error from server (AlreadyExists): services "example-web-go" already exists` here. This is because the `oc new-app` command you executed during lab 3 already created a service. This is the default behavior of `oc new-app`  while `oc create deployment` doesn't have this functionality.

As a consequence, the `oc expose` command above doesn't add anything new but it demonstrates how to easily create a service based on a deployment.
{{% /onlyWhen %}}

Let's have a more detailed look at our Service:

```bash
{{% param cliToolName %}} get services --namespace <namespace>
```

Which gives you an output similar to this:

```bash
NAME             TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
example-web-go   ClusterIP  10.43.91.62   <none>        5000/TCP  
```

{{% alert title="Note" color="info" %}}
Service IP (CLUSTER-IP) addresses stay the same for the duration of the Service's lifespan.
{{% /alert %}}

By executing the following command:

```bash
{{% param cliToolName %}} get service example-web-go -o yaml --namespace <namespace>
```

You get additional information:

```
apiVersion: v1
kind: Service
metadata:
  ...
  labels:
    app: example-web-go
  managedFields:
    ...
  name: example-web-go
  namespace: <namespace>
  ...
spec:
  clusterIP: 10.43.91.62
  externalTrafficPolicy: Cluster
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: example-web-go
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```

The Service's `selector` defines which Pods are being used as Endpoints. This happens based on labels. Look at the configuration of Service and Pod in order to find out what maps to what:

```bash
{{% param cliToolName %}} get service example-web-go -o yaml --namespace <namespace>
```

```
...
  selector:
    app: example-web-go
...
```

With the following command you get details from the Pod:

{{% alert title="Note" color="info" %}}
First, get all Pod names from your namespace with (`{{% param cliToolName %}} get pods --namespace <namespace>`) and then replace \<pod\> in the following command. If you have installed and configured the bash completion, you can also press the TAB key for autocompletion of the Pod's name.
{{% /alert %}}

```bash
{{% param cliToolName %}} get pod <pod> -o yaml --namespace <namespace>
```

Let's have a look at the label section of the Pod and verify that the Service selector matches the Pod's labels:

```
...
  labels:
    app: example-web-go
...
```

This link between Service and Pod can also be displayed in an easier fashion with the `{{% param cliToolName %}} describe` command:


```bash
{{% param cliToolName %}} describe service example-web-go --namespace <namespace>
```

```
Name:                     example-web-go
Namespace:                example-ns
Labels:                   app=example-web-go
Annotations:              <none>
Selector:                 app=example-web-go
Type:                     ClusterIP
IP:                       10.39.240.212
Port:                     <unset>  5000/TCP
TargetPort:               5000/TCP
Endpoints:                10.36.0.8:5000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age    From                Message
  ----    ------                ----   ----                -------
```

The `Endpoints` show the IP addresses of all currently matched Pods.


## {{% task %}} Expose the Service

With the ClusterIP Service ready, we can now create the {{% onlyWhenNot openshift %}}Ingress{{% /onlyWhen %}}{{% onlyWhen openshift %}}Route{{% /onlyWhen %}} resource.
{{% onlyWhenNot openshift %}}
In order to create the Ingress resource, we first need to create the file `ingress.yaml` and change the `host` entry to match your environment:

{{% onlyWhenNot customer %}}
{{< readfile file="/content/en/docs/exposing-a-service/ingress.template.yaml" code="true" lang="yaml" >}}
{{% /onlyWhenNot %}}

{{% onlyWhen mobi %}}
{{< readfile file="/content/en/docs/exposing-a-service/ingress-mobi.template.yaml" code="true" lang="yaml" >}}
{{% /onlyWhen %}}


As you see in the resource definition at `spec.rules[0].http.paths[0].backend.service.name` we use the previously created `example-web-go` ClusterIP Service.

Let's create the Ingress resource with:

```bash
kubectl apply -f <path to ingress.yaml> --namespace <namespace>
```

{{% onlyWhenNot mobi %}}
Afterwards, we are able to access our freshly created Ingress at `http://example-web-go-<namespace>.<domain>`
{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}
Afterwards, we are able to access our app via our freshly created Ingress at `https://example-web-go-<namespace>.<appdomain>`. Although we have not configured the Ingress to use TLS, it is available with a `https` address. This is because of the setup at Mobiliar and not default behavior.
{{% /onlyWhen %}}
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}

```bash
oc expose service example-web-go --namespace <namespace>
```

The output should be:

```
route.route.openshift.io/example-web-go exposed
```

We are now able to access our app via the freshly created route at `http://example-web-go-<namespace>.<appdomain>`

Find your actual app URL by looking at your route (HOST/PORT):

```bash
oc get route --namespace <namespace>
```

Browse to the URL and check the output of your app.
{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
{{% alert title="Note" color="info" %}}
The `<appdomain>` is the default domain under which your applications will be accessible and is provided by your trainer. You can also use `oc get route example-web-go` to see the exact value of the exposed route.
{{% /alert %}}
{{% /onlyWhen %}}

{{% onlyWhenNot openshift %}}


## {{% task %}} Expose as NodePort

There's a second option to make a Service accessible from outside: Use a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport).

In order to switch the Service type, we are going to delete the `ClusterIP` Service that we've created before:


```bash
kubectl delete service example-web-go --namespace=<namespace>
```

With the following command we create a Service:

```bash
kubectl expose deployment example-web-go --type=NodePort --name=example-web-go --port=5000 --target-port=5000 --namespace <namespace>
```

Let's have a more detailed look at our Service:

```bash
kubectl get services --namespace <namespace>
```

Which gives you an output similar to this:

```bash
NAME             TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
example-web-go   NodePort   10.43.91.62   <none>        5000:30692/TCP  
```

The `NodePort` number is assigned by Kubernetes and stays the same as long as the Service is not deleted. A NodePort Service is more suitable for infrastructure tools than for public URLs.

{{% alert title="Note" color="info" %}}
If `NodePort` is not supported in your environment then you can use `--type=ClusterIP` (or omit this parameter completely as it is the default) and use port forwarding to the Service instead.

Head over to task 6.3 in [lab 6](../06/) to learn how to use port forwarding.
{{% /alert %}}


Open `http://<node-ip>:<node-port>` in your browser.
You can use any node IP as the Service is exposed on all nodes using the same `NodePort`. Use `kubectl get nodes -o wide` to display the IPs (`INTERNAL-IP`) of the available nodes.

```bash
kubectl get node -o wide
```

The output may vary depending on your setup:

```
NAME         STATUS   ROLES                      AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
lab-1   Ready    controlplane,etcd,worker   150m   v1.17.4   5.102.145.142   <none>        Ubuntu 18.04.3 LTS   4.15.0-66-generic   docker://19.3.8
lab-2   Ready    controlplane,etcd,worker   150m   v1.17.4   5.102.145.77    <none>        Ubuntu 18.04.3 LTS   4.15.0-66-generic   docker://19.3.8
lab-3   Ready    controlplane,etcd,worker   150m   v1.17.4   5.102.145.148   <none>        Ubuntu 18.04.3 LTS   4.15.0-66-generic   docker://19.3.8
```

{{% onlyWhen rancher %}}
{{% alert title="Note" color="info" %}}
You can also use the Rancher web console to open the exposed application in your browser. The direct link is shown on your **Resources / Workload** page in the tab **Workload**. Look for your namespace and the deployment name. The link looks like `31665/tcp`.

{{< imgproc nodeportrancher.png Resize  "500x" >}}{{< /imgproc >}}

Or go to the **Service Discovery** tab and look for your Service name. The link there looks the same and is right below the Service name.
{{% /alert %}}
{{% /onlyWhen %}}
{{% /onlyWhenNot %}}


## {{% task %}} For fast learners

Have a closer look at the resources created in your namespace `<namespace>` with the following commands and try to understand them:

```bash
{{% param cliToolName %}} describe namespace <namespace>
```

```bash
{{% param cliToolName %}} get all --namespace <namespace>
```

```bash
{{% param cliToolName %}} describe <resource> <name> --namespace <namespace>
```

```bash
{{% param cliToolName %}} get <resource> <name> -o yaml --namespace <namespace>
```
