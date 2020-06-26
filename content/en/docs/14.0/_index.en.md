---
title: "14. Web Console"
weight: 14
sectionnumber: 14
---


To make Kubernetes workload visible there are many options. In our limited namespace we are not allowed to create a read-only user who can access more than your own namespace. Therefore we are using a small Web Console which can be installed in your Namespace und make your workload visible.

The [Web Console](http://kubeview.benco.io/) we are using is a small project to make some Kubernetes ressources visible manage complex Kubernetes configurations.
In this lab we will deploy the Web Console to our Namespace.


## Task {{% param sectionnumber %}}.1: Install the Web Console

To install the Web Console into your existing Namespace you have to execute the following

```bash
kubectl apply -f https://raw.githubusercontent.com/acend/kubernetes-techlab/master/content/en/docs/14.0/dashboard.yaml --namespace <namespace>
```


## Task {{% param sectionnumber %}}.2: Access the Web Console

The Web Console will not deploy an Ingress for you.
We will use the `kubectl port-forward` function to access the Web Console in the Browser.

By executing the following, `kubectl` will act as an [proxy](https://en.wikipedia.org/wiki/Proxy_server) and forward the port from the service to your local client.

```bash
kubectl port-forward service/kubeview 8080:80 --namespace <namespace>
```

Now click on this link to access the Web Console: <http://localhost:8080>
It can only be accessed from a client who executed the `kubectl port-forward` command


## Task {{% param sectionnumber %}}.3: Find your workload

After opening the Web Console on your local client, you should see ... nothing. Why is that?
As mentioned before, the Web Console is limited to your Namespace. So find the search field in the head of the page and type in your Namespace.

Now you should see all your deployments in your Namespace.


## Task {{% param sectionnumber %}}.4: Scale your workload

After you have completed the Labs before you should now be able to scale parts of your workload. You will see how the Web Console changes after refreshing the page. Let's do it!


## Additional informations

This Lab is just a small demonstration of an working Web Console for Kubernetes. To get an idea of other Dashboards check the following links for more informations.

* [GitHub Repo (kubeview)](https://github.com/benc-uk/kubeview)
* [Official Web Console](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
* [Another Web Console](https://kube-web-view.readthedocs.io/en/latest/)

