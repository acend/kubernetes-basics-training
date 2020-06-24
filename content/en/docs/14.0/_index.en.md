---
title: "14. Web UI (Dashboard)"
weight: 14
sectionnumber: 14
---


The [Web UI](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) is a project from the [Kubernetes Special Interest Groups (SIGs)](https://kubernetes.io/community/) to manage complex Kubernetes configurations.
In this lab we will deploy the Web UI to our Namespace.


## Task {{% param sectionnumber %}}.1: Install the Web UI

To install the Web UI into your existing Namespace you have to execute the following 

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml --namespace <namespace>
```

## Task {{% param sectionnumber %}}.2: Access the Web UI

The Web UI will not deploy a Service or an Ingress for you.
We will use the `kubectl proxy` function to access the Web UI in the Browser.

By executing the following, `kubectl` will act as an [proxy](https://en.wikipedia.org/wiki/Proxy_server) and you have direct access to the Kubernetes API from your client

```
kubectl proxy
```

Now click on this link to access the Web UI: <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.>
It can only be accessed from a client who executed the `kubectl proxy` command

## Task {{% param sectionnumber %}}.3: Find your container logs

You should have open the Web UI and see some information from the Kubernetes Cluster. As your user may be limited to see just some ressources you may get some error messages about missing ressources.

Navigate to your former deployed containers and check if you are able to get the logfiles from them via the Web UI.

## Additional informations

* [Official documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#using-dashboard)
* [GitHub Repo](https://github.com/kubernetes/dashboard)
