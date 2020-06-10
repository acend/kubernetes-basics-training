---
title: "5. Exposing a Service"
weight: 5
sectionnumber: 5
---

In this lab, we are going to make the freshly deployed application from the last lab available online.

The command `kubectl create deployment` from the last lab creates a Pod but no Service. A Service is another Kubernetes concept which we'll need in order to make our application available online. We're going to do this with the command `kubectl expose`. As soon as we then expose the Service itself, it is available online.


## Task {{% param sectionnumber %}}.1: Expose as NodePort

With the following command we create a Service and by doing this we expose our Deployment. There are different kinds of Services. For this example, we are going to use the [`NodePort`](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) type and expose port 5000:

```bash
kubectl expose deployment example-web-go --type=NodePort --name=example-web-go --port=5000 --target-port=5000 --namespace <namespace>
```

{{% alert title="Note" color="warning" %}}
If `NodePort` is not supported in your environment then you can use `--type=ClusterIP` (or omit this parameter completely as it is the default) and use port forwarding to the Service instead.

Head over to task 7.3 in [lab 7](../07.0) to learn how to use port forwarding.
{{% /alert %}}

[Services](https://kubernetes.io/docs/concepts/services-networking/service/) in Kubernetes serve as an abstraction layer, entry point and proxy/load balancer for Pods. A Service makes it possible to group and address Pods from the same kind.

As an example: If a replica of our application Pod cannot handle the load anymore, we can simply scale our application to more Pods in order to distribute the load. Kubernetes automatically maps these Pods as the Service's backends/endpoints. As soon as the Pods are ready, they'll receive requests.

{{% alert title="Note" color="warning" %}}
The application is not yet accessible from outside, the Service is a Kubernetes internal concept. We're going to fully expose the application in the next lab.
{{% /alert %}}

Let's have a more detailed look at our Service:

```bash
kubectl get services --namespace <namespace>
```

Which gives you an output similar to this:

```bash
NAME             TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
example-web-go   NodePort   10.43.91.62   <none>        5000:30692/TCP  
```

The `NodePort` number is being assigned by Kubernetes and stays the same as long as the Services is not deleted. A `NodePort` Service is more suitable for infrastructure tools than for public URLs. But don't worry, we are going to do that later too with Ingress mappings that create better readable URLs.

You get additional information by executing the following command:

```bash
kubectl get service example-web-go -o json --namespace <namespace>
```

```json
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
                "nodePort": 30692,
                "port": 5000,
                "protocol": "TCP",
                "targetPort": 5000
            }
        ],
        "selector": {
            "app": "example-web-go"
        },
        "sessionAffinity": "None",
        "type": "NodePort"
    },
    "status": {
        "loadBalancer": {}
    }
}
```

With the appropriate command you get details from the Pod (or any other resource):

```bash
kubectl get pod example-web-go-3-nwzku -o json --namespace <namespace>
```

{{% alert title="Note" color="warning" %}}
First, get all Pod names from your namespace with (`kubectl get pods --namespace <namespace>`) and then replace it in the following command.
{{% /alert %}}

The Service's `selector` defines, which Pods are being used as Endpoints. This happens based on labels. Look at the configuration of Service and Pod in order to find out what maps to what:

Service:

```bash
kubectl get service example-web-go -o json --namespace <namespace>
```

```json
...
"selector": {
    "app": "example-web-go",
},
...
```

Pod:

```bash
kubectl get pod <pod> -o json --namespace <namespace>
```

```json
...
"labels": {
    "app": "example-web-go",
},
...
```

This link between Service and Pod can be displayed in an easier fashion with the `kubectl describe` command:

```bash
kubectl describe service example-web-go --namespace <namespace>
```

```
Name:                     example-web-go
Namespace:                philipona
Labels:                   app=example-web-go
Annotations:              <none>
Selector:                 app=example-web-go
Type:                     NodePort
IP:                       10.39.240.212
Port:                     <unset>  5000/TCP
TargetPort:               5000/TCP
NodePort:                 <unset>  30100/TCP
Endpoints:                10.36.0.8:5000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age    From                Message
  ----    ------                ----   ----                -------
```

{{% alert title="Note" color="warning" %}}
Service IP addresses stay the same for the duration of the Service's lifespan.
{{% /alert %}}

Open `http://<node-ip>:<node-port>` in your browser.
You can use any node IP as the Service is exposed on all nodes using the same `NodePort`. Use `kubectl get nodes -o wide` to display the IPs (`INTERNAL-IP`) of the available nodes.

```bash
kubectl get node -o wide
```

```
NAME         STATUS   ROLES                      AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
lab-1   Ready    controlplane,etcd,worker   150m   v1.17.4   5.102.145.142   <none>        Ubuntu 18.04.3 LTS   4.15.0-66-generic   docker://19.3.8
lab-2   Ready    controlplane,etcd,worker   150m   v1.17.4   5.102.145.77    <none>        Ubuntu 18.04.3 LTS   4.15.0-66-generic   docker://19.3.8
lab-3   Ready    controlplane,etcd,worker   150m   v1.17.4   5.102.145.148   <none>        Ubuntu 18.04.3 LTS   4.15.0-66-generic   docker://19.3.8
```

{{% onlyWhen rancher %}}
{{% alert title="Note" color="warning" %}}
You can also use the Rancher web console to open the exposed application in your browser. The direkt link is shown on your **Resources / Workload** page in the tab **Workload**. Look for your namespace and the deployment name. The link looks like `31665/tcp`.

![Rancher NodePort](nodeportrancher.png)

Or go to the **Service Discovery** tab and look for your Service name. The link there looks the same and is right below the Service name.
{{% /alert %}}
{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.2: Create an ClusterIP Service with an Ingress

There's a second option to make a Service accessible from outside: Use an Ingress router.

In order to switch the Service type, we are going to delete the `NodePort` Service that we've created before:

```bash
kubectl delete service example-web-go --namespace=<namespace>
```

Now we create a Service with type [ClusterIP](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types):

```bash
kubectl expose deployment example-web-go --type=ClusterIP --name=example-web-go --port=5000 --target-port=5000 --namespace <namespace>
```

In order to create the Ingress resource, we first need to create the file `ingress.yaml` and change the host variable to match your environment.

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

After creating the Ingress file, we can apply it:

```bash
kubectl create -f ingress.yaml --namespace <namespace>
```

Afterwards, we are able to access our freshly created Service at `http://web-go-<namespace>.<domain>`


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
