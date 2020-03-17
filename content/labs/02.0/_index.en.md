---
title: "2.0 - Create a simple Chart"
weight: 20
---


### Task 1

```bash
helm create mychart
```

This template is already a valid and fully functional chart which deploys NGINX. Have a look now on the generated files and their content. For an explanation of the files, visit the [Helm Developer Documentation](https://docs.helm.sh/developing_charts/#the-chart-file-structure). In a later Section you find all the information about Helm templates


### Task 2

Before actually deploying our generated chart, we can check the (to be) generated Kubernetes ressources with the following Command:

```bash
helm install --dry-run --debug --namespace [USER]-dockerimage mychart
```

Finally, the following command creates a new Release with the Helm chart and deploys the application::

```bash
helm install mychart --namespace [USER]-dockerimage
```

With kubectl get pods --namespace [USER]-dockerimage you should see a new Pod. You can list the newly created Helm release with 
the following command:

```bash
helm ls --namespace [USER]-dockerimage
```


### Task 3

Your deployed NGINX is not yet accessible from external. To expose it, you have to change the Service Type to NodePort. Search 
now for the service type definition in your chart and make the change. You can apply your change with the following command:

```bash
helm upgrade [RELEASE] --namespace [namespace] mychart
```

As soon as the Service has a NodePort, you will see it with the following command (As we use -w (watch) you have to terminate the command with CTRL-C):

```bash
kubectl get svc --namespace [namespace] -w
```

NGINX is now available at the given NodePort and should display a welcome-page when accessing it with curl or you can also open the page in your browser:


### Task 4

To remove an application, you can simply remove the Helm release with the following command:

```bash
helm delete [RELEASE]
```

With `kubectl get pods --namespace [USER]-dockerimage` you should now longer see your application Pod.