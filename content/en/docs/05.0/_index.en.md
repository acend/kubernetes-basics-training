---
title: "5. Exposing a Service"
weight: 5
sectionnumber: 5
---

In this lab, we are going to make the freshly deployed application from the last lab available online.


## Task {{% param sectionnumber %}}.1: Create an ClusterIP Service with an Ingress

The command `kubectl create deployment` from the last lab creates a Pod but no Service. A Kubernetes Service is an abstract way to expose an application running on a set of Pods as a network service. For some parts of your application (for example, frontends) you may want to expose a Service onto an external IP address, that's outside of your cluster.

Kubernetes `ServiceTypes` allow you to specify what kind of Service you want. The default is `ClusterIP`.

`Type` values and their behaviors are:

* `ClusterIP`: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType.

* `NodePort`: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting \<NodeIP\>:\<NodePort\>.

* `LoadBalancer`: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.

* `ExternalName`: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up.

You can also use Ingress to expose your Service. Ingress is not a Service type, but it acts as the entry point for your cluster. [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource. An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL / TLS, and offer name based virtual hosting. An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

In order to use an Ingress, we first need to create a Service of type [ClusterIP](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types). We're going to do this with the command `kubectl expose`:

```bash
kubectl expose deployment example-web-go --type=ClusterIP --name=example-web-go --port=5000 --target-port=5000 --namespace <namespace>
```

Let's have a more detailed look at our Service:

```bash
kubectl get services --namespace <namespace>
```

Which gives you an output similar to this:

```bash
NAME             TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
example-web-go   ClusterIP  10.43.91.62   <none>        5000/TCP  
```

{{% alert title="Note" color="primary" %}}
Service IP (CLUSTER-IP) addresses stay the same for the duration of the Service's lifespan.
{{% /alert %}}

You get additional information by executing the following command:

```bash
kubectl get service example-web-go -o json --namespace <namespace>
```

```
{
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
        "creationTimestamp": "2019-06-21T06:25:38Z",
        "labels": {
            "app": "example-web-go"
        },
        "name": "example-web-go",
        "namespace": "team1-dockerimage",
        "resourceVersion": "102747",
        "selfLink": "/api/v1/namespaces/team1-dockerimage/services/example-web-go",
        "uid": "62ce2e59-93ed-11e9-b6c9-5a4205669108"
    },
    "spec": {
        "clusterIP": "10.43.91.62",
        "externalTrafficPolicy": "Cluster",
        "ports": [
            {
                "port": 5000,
                "protocol": "TCP",
                "targetPort": 5000
            }
        ],
        "selector": {
            "app": "example-web-go"
        },
        "sessionAffinity": "None",
        "type": "ClusterIP"
    },
    "status": {
        "loadBalancer": {}
    }
}
```

The Service's `selector` defines, which Pods are being used as Endpoints. This happens based on labels. Look at the configuration of Service and Pod in order to find out what maps to what:

```bash
kubectl get service example-web-go -o json --namespace <namespace>
```

```
...
"selector": {
    "app": "example-web-go",
},
...
```

With the following command you get details from the Pod:

{{% alert title="Note" color="primary" %}}
First, get all Pod names from your namespace with (`kubectl get pods --namespace <namespace>`) and then replace \<pod\> it in the following command. If you have installed the bash completion, you can also press TAB key for autocompletion of the Pods name.
{{% /alert %}}

```bash
kubectl get pod <pod> -o json --namespace <namespace>
```

Let's have a look at the label section of the Pod and verify that the Service selector matches with the Pod's labels:

```
...
"labels": {
    "app": "example-web-go",
},
...
```

This link between Service and Pod can also be displayed in an easier fashion with the `kubectl describe` command:


```bash
kubectl describe service example-web-go --namespace <namespace>
```

```
Name:                     example-web-go
Namespace:                philipona
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

The `Endpoints` shows the IP addresses of all currently matched Pods.

With the ClusterIP Service ready, we can now create the Ingress resource. In order to create the Ingress resource, we first need to create the file `ingress.yaml` and change the host variable to match your environment.
{{< onlyWhenNot mobi >}}

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example-web-go
spec:
  rules:
  - host: example-web-go-<namespace>.<domain>
    http:
      paths:
      - path: /
        backend:
          serviceName: example-web-go
          servicePort: 5000
```

{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example-web-go
spec:
  rules:
  - host: example-web-go-<namespace>.phoenix.mobicorp.test
    http:
      paths:
      - path: /
        backend:
          serviceName: example-web-go
          servicePort: 5000
```

{{< /onlyWhen >}}

As you see in the resource definition at `spec.rules[0].http.paths[0].backend.serviceName` we use the previously created `example-web-go` ClusterIP Service.

Let's create the Ingress with:

```bash
kubectl create -f ingress.yaml --namespace <namespace>
```

{{< onlyWhenNot mobi >}}
Afterwards, we are able to access our freshly created Ingress at `http://web-go-<namespace>.<domain>`
{{< /onlyWhenNot >}}
{{< onlyWhen mobi >}}
Afterwards, we are able to access our freshly created Ingress at `http://web-go-<namespace>.phoenix.mobicorp.test`. It might take some minutes until the DNS for your Ingress is created. You can verify the Ingress later.
{{< /onlyWhen >}}


## Task {{% param sectionnumber %}}.2: Expose as NodePort

There's a second option to make a Service accessible from outside: Use an `[NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)`.

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

The `NodePort` number is being assigned by Kubernetes and stays the same as long as the Services is not deleted. A NodePort Service is more suitable for infrastructure tools than for public URLs.

{{% alert title="Note" color="primary" %}}
If `NodePort` is not supported in your environment then you can use `--type=ClusterIP` (or omit this parameter completely as it is the default) and use port forwarding to the Service instead.

Head over to task 7.3 in [lab 7](../07.0) to learn how to use port forwarding.
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
{{% alert title="Note" color="primary" %}}
You can also use the Rancher web console to open the exposed application in your browser. The direkt link is shown on your **Resources / Workload** page in the tab **Workload**. Look for your namespace and the deployment name. The link looks like `31665/tcp`.

![Rancher NodePort](nodeportrancher.png)

Or go to the **Service Discovery** tab and look for your Service name. The link there looks the same and is right below the Service name.
{{% /alert %}}
{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.3 (optional): For fast learners

Have a closer look at the resources created in your namespace `<namespace>` with the following commands and try to understand them:

```bash
kubectl describe namespace <namespace>
```

```bash
kubectl get all --namespace <namespace>
```

```bash
kubectl describe <resource> <name> --namespace <namespace>
```

```bash
kubectl get <resource> <name> -o json --namespace <namespace>
```


## Task {{% param sectionnumber %}}.4: Clean up

As a last step, clean up the remaining resources so that we have a clean namespace to continue.

Delete the Deployment:

```bash
kubectl delete deployment example-web-go --namespace <namespace>
```

Delete the Service:

```bash
kubectl delete service example-web-go --namespace <namespace>
```

Delete the Ingress:

```bash
kubectl delete ingress example-web-go --namespace <namespace>
```
