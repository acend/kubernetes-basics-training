---
title: "14. Web Console"
weight: 14
sectionnumber: 14
---


In this lab you will deploy the Web Console to your Namespace.

To make Kubernetes workload visible there are many options. In our limited namespace we are not allowed to create a read-only user who can access more than our own namespace. Therefore this labs uses a small Web Console which can be installed in our Namespace to make our workload visible.

The [Web Console](http://kubeview.benco.io/) which will be used, is a small project to make some Kubernetes ressources visible.


## Task {{% param sectionnumber %}}.1: Install the Web Console

To install the Web Console into our existing Namespace we have to execute the following:

```bash
kubectl apply -f https://raw.githubusercontent.com/acend/kubernetes-techlab/master/content/en/docs/14/dashboard.yaml --namespace <namespace>
```


## Task {{% param sectionnumber %}}.2: Access the Web Console

The Web Console will not deploy an Ingress for us.
We will use the `kubectl port-forward` function to access the Web Console in a browser.

By executing the following, `kubectl` will act as an [proxy](https://en.wikipedia.org/wiki/Proxy_server) and forward the port from the service to our local client.

```bash
kubectl port-forward service/kubeview 8080:80 --namespace <namespace>
```

Now click on this link to access the Web Console: <http://localhost:8080>
It can only be accessed from a client who executed the `kubectl port-forward` command.


## Task {{% param sectionnumber %}}.3: Find your workload

After opening the Web Console on our browser, we will see ... nothing. But why is that?
As mentioned before, the Web Console is limited to our Namespace. Find the search field in the head of the page and type in our Namespace.

Now we see all our deployments in our Namespace.


## Task {{% param sectionnumber %}}.4: Scale your workload

Since we have completed all the Labs before we should now be able to scale the Pods from our workload. We will see how the Web Console changes after refreshing the page. Let's do it!


## Additional informations

This Lab is just a small demonstration of an working Web Console for Kubernetes. To get an idea of other Dashboards check the following links for more informations.

* [GitHub Repo (kubeview)](https://github.com/benc-uk/kubeview)
* [Official Web Console](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
* [Another Web Console](https://kube-web-view.readthedocs.io/en/latest/)

