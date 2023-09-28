---
title: "Network policies"
weight: 101
---

## Network Policies

One CNI function is the ability to enforce network policies and implement an in-cluster zero-trust container strategy. Network policies are a default Kubernetes object for controlling network traffic, but a CNI such as [Cilium](https://cilium.io/) or [Calico](https://www.tigera.io/project-calico/) is required to enforce them. We will demonstrate traffic blocking with our simple app.

{{% alert title="Note" color="primary" %}}
If you are not yet familiar with Kubernetes Network Policies we suggest going to the [Kubernetes Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
{{% /alert %}}

{{% onlyWhen openshift %}}
{{% alert title="Warning" color="warning" %}}
For this lab to work it is vital that you use the namespace `<username>-netpol`!
{{% /alert %}}
{{% /onlyWhen %}}

### {{% task %}} Deploy a simple frontend/backend application

First we need a simple application to show the effects on Kubernetes network policies. Let's have a look at the following resource definitions:

{{< readfile file="/content/en/docs/security/network-policies/simple-app.yaml" code="true" lang="yaml" >}}

The application consists of two client deployments (`frontend` and `not-frontend`) and one backend deployment (`backend`). We are going to send requests from the frontend and not-frontend pods to the backend pod.

Create a file `simple-app.yaml` with the above content.

{{% onlyWhen openshift %}}
{{% alert title="Warning" color="warning" %}}
Remember to use the namespace `<username>-netpol`, otherwise this lab will not work!
{{% /alert %}}
{{% /onlyWhen %}}

Deploy the app:

{{% onlyWhen openshift %}}
```bash
kubectl apply -f simple-app.yaml --namespace <namespace>-netpol
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl apply -f simple-app.yaml
```
{{% /onlyWhenNot %}}

this gives you the following output:

```
deployment.apps/frontend created
deployment.apps/not-frontend created
deployment.apps/backend created
service/backend created
```

Verify with the following command that everything is up and running:

{{% onlyWhen openshift %}}
```bash
kubectl get all --namespace <namespace>-netpol
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl get all
```
{{% /onlyWhenNot %}}


```
NAME                               READY   STATUS    RESTARTS   AGE
pod/backend-65f7c794cc-b9j66       1/1     Running   0          3m17s
pod/frontend-76fbb99468-mbzcm      1/1     Running   0          3m17s
pod/not-frontend-8f467ccbd-cbks8   1/1     Running   0          3m17s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/backend      ClusterIP   10.97.228.29   <none>        8080/TCP   3m17s
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP    45m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend        1/1     1            1           3m17s
deployment.apps/frontend       1/1     1            1           3m17s
deployment.apps/not-frontend   1/1     1            1           3m17s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-65f7c794cc       1         1         1       3m17s
replicaset.apps/frontend-76fbb99468      1         1         1       3m17s
replicaset.apps/not-frontend-8f467ccbd   1         1         1       3m17s
```

Let us make life a bit easier by storing the pods name into an environment variable so we can reuse it later again:

{{% onlyWhen openshift %}}
```bash
export FRONTEND=$(kubectl get pods -l app=frontend --namespace <namespace>-netpol -o jsonpath='{.items[0].metadata.name}')
echo ${FRONTEND}
export NOT_FRONTEND=$(kubectl get pods -l app=not-frontend --namespace <namespace>-netpol -o jsonpath='{.items[0].metadata.name}')
echo ${NOT_FRONTEND}
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
export FRONTEND=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo ${FRONTEND}
export NOT_FRONTEND=$(kubectl get pods -l app=not-frontend -o jsonpath='{.items[0].metadata.name}')
echo ${NOT_FRONTEND}
```
{{% /onlyWhenNot %}}


## {{% task %}} Verify connectivity

Now we generate some traffic as a baseline test.

{{% onlyWhen openshift %}}
```bash
kubectl exec --namespace <namespace>-netpol -ti ${FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```

and


```bash
kubectl exec --namespace <namespace>-netpol -ti ${NOT_FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl exec -ti ${FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```

and


```bash
kubectl exec -ti ${NOT_FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```
{{% /onlyWhenNot %}}


This will execute a simple `curl` call from the `frontend` and `not-frondend` application to the `backend` application:

```
# Frontend
HTTP/1.1 200 OK
X-Powered-By: Express
Vary: Origin, Accept-Encoding
Access-Control-Allow-Credentials: true
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Last-Modified: Sat, 26 Oct 1985 08:15:00 GMT
ETag: W/"83d-7438674ba0"
Content-Type: text/html; charset=UTF-8
Content-Length: 2109
Date: Tue, 23 Nov 2021 12:50:44 GMT
Connection: keep-alive

# Not Frontend
HTTP/1.1 200 OK
X-Powered-By: Express
Vary: Origin, Accept-Encoding
Access-Control-Allow-Credentials: true
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Last-Modified: Sat, 26 Oct 1985 08:15:00 GMT
ETag: W/"83d-7438674ba0"
Content-Type: text/html; charset=UTF-8
Content-Length: 2109
Date: Tue, 23 Nov 2021 12:50:44 GMT
Connection: keep-alive
```

and we see, both applications can connect to the `backend` application.

Until now ingress and egress policy enforcement are still disabled on all of our pods because no network policy has been imported yet selecting any of the pods. Let us change this.


## {{% task %}} Deny traffic with a Network Policy

We block traffic by applying a network policy. Create a file `backend-ingress-deny.yaml` with the following content:

{{< readfile file="/content/en/docs/security/network-policies/backend-ingress-deny.yaml" code="true" lang="yaml" >}}

The policy will deny all ingress traffic as it is of type Ingress but specifies no allow rule, and will be applied to all pods with the `app=backend` label thanks to the podSelector.

Ok, then let's create the policy with:

{{% onlyWhen openshift %}}
```bash
kubectl apply -f backend-ingress-deny.yaml --namespace <namespace>-netpol
```

and you can verify the created `NetworkPolicy` with:

```bash
kubectl get netpol --namespace <namespace>-netpol
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl apply -f backend-ingress-deny.yaml
```

and you can verify the created `NetworkPolicy` with:

```bash
kubectl get netpol
```
{{% /onlyWhenNot %}}

which gives you an output similar to this:

```
                                                    
NAME                   POD-SELECTOR   AGE
backend-ingress-deny   app=backend    2s

```


## {{% task %}} Verify connectivity again

We can now execute the connectivity check again:

{{% onlyWhen openshift %}}
```bash
kubectl exec --namespace <namespace>-netpol -ti ${FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```

and

```bash
kubectl exec --namespace <namespace>-netpol -ti ${NOT_FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl exec -ti ${FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```

and

```bash
kubectl exec -ti ${NOT_FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```
{{% /onlyWhenNot %}}

but this time you see that the `frontend` and `not-frontend` application cannot connect anymore to the `backend`:

```
# Frontend
curl: (28) Connection timed out after 5001 milliseconds
command terminated with exit code 28
# Not Frontend
curl: (28) Connection timed out after 5001 milliseconds
command terminated with exit code 28
```

The network policy correctly switched the default ingress behavior from default allow to default deny.

Let's now selectively re-allow traffic again, but only from frontend to backend.


## {{% task %}} Allow traffic from frontend to backend

We can do it by crafting a new network policy manually, but we can also use the Network Policy Editor made by Cilium to help us out:

![Cilium editor with backend-ingress-deny Policy](cilium_editor_1.png)

Above you see our original policy, we create an new one with the editor now.

* Go to https://editor.cilium.io/
* Name the network policy to backend-allow-ingress-frontend (using the Edit button in the center).
* add `app=backend` as Pod Selector
* Set Ingress to default deny

![Cilium editor edit name](cilium_editor_edit_name.png)

* On the ingress side, add `app=frontend` as podSelector for pods in the same Namespace.

![Cilium editor add rule](cilium_editor_add.png)

* Inspect the ingress flow colors: the policy will deny all ingress traffic to pods labeled `app=backend`, except for traffic coming from pods labeled `app=frontend`.

![Cilium editor backend allow rule](cilium_editor_backend-allow-ingress.png)


* Copy the policy YAML into a file named `backend-allow-ingress-frontend.yaml`. Make sure to use the `Networkpolicy` and not the `CiliumNetworkPolicy`!

The file should look like this:

{{< readfile file="/content/en/docs/security/network-policies/backend-allow-ingress-frontend.yaml" code="true" lang="yaml" >}}

Apply the new policy:

{{% onlyWhen openshift %}}
```bash
kubectl apply -f backend-allow-ingress-frontend.yaml --namespace <namespace>-netpol
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl apply -f backend-allow-ingress-frontend.yaml
```
{{% /onlyWhenNot %}}

and then execute the connectivity test again:

{{% onlyWhen openshift %}}
```bash
kubectl exec --namespace <namespace>-netpol -ti ${FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```

and

```bash
kubectl exec --namespace <namespace>-netpol -ti ${NOT_FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl exec -ti ${FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```

and

```bash
kubectl exec -ti ${NOT_FRONTEND} -- curl -I --connect-timeout 5 backend:8080
```
{{% /onlyWhenNot %}}

This time, the `frontend` application is able to connect to the `backend` but the `not-frontend` application still cannot connect to the `backend`:

```
# Frontend
HTTP/1.1 200 OK
X-Powered-By: Express
Vary: Origin, Accept-Encoding
Access-Control-Allow-Credentials: true
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Last-Modified: Sat, 26 Oct 1985 08:15:00 GMT
ETag: W/"83d-7438674ba0"
Content-Type: text/html; charset=UTF-8
Content-Length: 2109
Date: Tue, 23 Nov 2021 13:08:27 GMT
Connection: keep-alive

# Not Frontend
curl: (28) Connection timed out after 5001 milliseconds
command terminated with exit code 28

```

Note that this is working despite the fact we did not delete the previous `backend-ingress-deny` policy:

{{% onlyWhen openshift %}}
```bash
kubectl get netpol --namespace <namespace>-netpol
```
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}
```bash
kubectl get netpol
```
{{% /onlyWhenNot %}}

```
NAME                             POD-SELECTOR   AGE
backend-allow-ingress-frontend   app=backend    2m7s
backend-ingress-deny             app=backend    12m

```

Network policies are additive. Just like with firewalls, it is thus a good idea to have default DENY policies and then add more specific ALLOW policies as needed.
