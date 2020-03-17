---
title: "3.0 - Deploy a more complex Application"
weight: 30
---

In this extended lab, we are going to deploy an existing application with a Helm chart

### Helm Hub

Check out [Helm Hub](https://hub.helm.sh/), there you find a lot of Helm charts. For this lab, we choose [HackMD](https://hub.helm.sh/charts/stable/hackmd) a realtime, multiplatform collaborative markdown note editor.

### HackMD

The official HackMD Helm-Chart ist published in the stable Helm repository. First, make sure that you have the stable repo added in your Helm client.

```
helm repo list
NAME           	URL                                              
stable         	https://kubernetes-charts.storage.googleapis.com 
local          	http://127.0.0.1:8879/charts
```


which should already be the case. If, for any reason, you don't have the stable repo, you can add it by typing:

```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```

Let's check the available configuration for this Helm chart. Normally you find them in the `values.yaml` File inside the repository or described in the charts readme.

We are going to override some of the values, for that purpose, create a new values.yaml file locally on your workstation with the following content:

```yaml
image:
  tag: 1.3.0-alpine
persistence:
  storageClass: TODO
  size: 1Gi
ingress:
  enabled: true
  hosts:
    - TODO
postgresql:
  persistence:
    size: 1Gi
    storageClass: TODO
  postgresPassword: my-secret-password
```


If you look inside the requirements.yaml file of the HackMD Chart you see a dependency to the postgresql Helm chart. All the postgresql values are used by this dependent Helm chart and the chart is automaticly deployed when installing HackMD.

Now deploy the application with:

```
helm install -f values.yaml stable/hackmd
```

Watch the deployed application with helm ls and also check the Rancher WebGUI for the newly created Deployments, the Ingress and also the PersistenceVolumeClaim.

```
helm ls
NAME             	REVISION	UPDATED                 	STATUS  	CHART       	APP VERSION 	NAMESPACE        
altered-billygoat	1       	Thu Sep 26 14:06:59 2019	DEPLOYED	hackmd-1.2.1	1.3.0-alpine	team1-dockerimage
```

As soon as all Deployments are ready (hackmd and postgres) you can open the application with the URL from your `values.yaml` file or by using the link inside the Rancher WebGUI.


### Upgrade

We are now going to upgrade the application to a newer Container image. You can do this with:

```
helm upgrade --reuse-values --set image.tag=1.3.1-alpine quiet-squirrel stable/hackmd
```

*Note*: Make sure to use the correct release name, as shown with the helm ls command.


And then observe how the Deployment was changed to a the new container image tag.

### Cleanup

helm delete --purge altered-billygoat
