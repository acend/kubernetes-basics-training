---
title: "Create a chart"
weight: 123
onlyWhenNot: baloise
---

In this lab we are going to create our very first Helm chart and deploy it.


## {{% task %}} Create Chart

First, let's create our chart. Open your favorite terminal and make sure you're in the workspace for this lab, e.g. `cd ~/<workspace-kubernetes-training>`:

```bash
helm create mychart
```

You will now find a `mychart` directory with the newly created chart. It already is a valid and fully functional chart which deploys an nginx instance. Have a look at the generated files and their content. For an explanation of the files, visit the [Helm Developer Documentation](https://docs.helm.sh/developing_charts/#the-chart-file-structure). In a later section you'll find all the information about Helm templates.

{{% onlyWhen mobi %}}
Because you cannot pull the `nginx` container image on your cluster, you have to use the `REGISTRY-URL/puzzle/k8s/kurs/nginx` container image. Change your `mychart/values.yaml` to match the following:

```yaml
[...]
image:
  repository: REGISTRY-URL/puzzle/k8s/kurs/nginx
  tag: stable
  pullPolicy: IfNotPresent
[...]
```

{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
The default image freshly created chart deploys is a simple nginx image listening on port `80`.

Since OpenShift doesn't allow to run containers as root by default, we need to change the default image to an unprivileged one (`{{% param "images.nginxinc-nginx-unprivileged" %}}`) and also change the containerPort to `8080`.

Change the image in the `mychart/values.yaml`

```yaml
...
image:
  repository: {{% param "images.nginxinc-nginx-unprivileged" %}}
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "latest"
...
```

And then change the containerPort in the `mychart/templates/deployment.yaml`

```yaml
...
ports:
- name: http
  containerPort: 8080
  protocol: TCP
...
```

{{% /onlyWhen %}}


## {{% task %}} Install Release

Before actually deploying our generated chart, we can check the (to be) generated Kubernetes resources with the following command:


```bash
helm install --dry-run --debug --namespace $USER myfirstrelease ./mychart
```


Finally, the following command creates a new release and deploys the application:

```bash
helm install --namespace $USER myfirstrelease ./mychart
```


With `{{% param cliToolName %}} get pods --namespace $USER` you should see a new Pod:

```bash
NAME                                     READY   STATUS    RESTARTS   AGE
myfirstrelease-mychart-6d4956b75-ng8x4   1/1     Running   0          2m21s
```

You can list the newly created Helm release with the following command:

```bash
helm ls --namespace $USER
```


## {{% task %}} Expose Application

Our freshly deployed nginx is not yet accessible from outside the {{% param distroName %}} cluster.
To expose it, we have to make sure a so called ingress resource will be deployed as well.
{{% onlyWhenNot mobi %}}<!-- No TLS on mobi ingress-->
Also make sure the application is accessible via TLS.
{{% /onlyWhenNot %}}

A look into the file `templates/ingress.yaml` reveals that the rendering of the ingress and its values is configurable through values(`values.yaml`):

```yaml
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "mychart.fullname" . -}}
{{- $svcPort := .Values.service.port -}}
{{- if and .Values.ingress.className (not (semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion)) }}
  {{- if not (hasKey .Values.ingress.annotations "kubernetes.io/ingress.class") }}
  {{- $_ := set .Values.ingress.annotations "kubernetes.io/ingress.class" .Values.ingress.className}}
  {{- end }}
{{- end }}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- else if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if and .Values.ingress.className (semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion) }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            {{- if and .pathType (semverCompare ">=1.18-0" $.Capabilities.KubeVersion.GitVersion) }}
            pathType: {{ .pathType }}
            {{- end }}
            backend:
              {{- if semverCompare ">=1.19-0" $.Capabilities.KubeVersion.GitVersion }}
              service:
                name: {{ $fullName }}
                port:
                  number: {{ $svcPort }}
              {{- else }}
              serviceName: {{ $fullName }}
              servicePort: {{ $svcPort }}
              {{- end }}
          {{- end }}
    {{- end }}
{{- end }}

```

{{% onlyWhenNot customer %}}
Thus, we need to change this value inside our `mychart/values.yaml` file. This is also where we enable the TLS part:

{{% alert title="Note" color="info" %}}
Make sure to replace the `<namespace>` and `<appdomain>` accordingly.
{{% /alert %}}

{{% onlyWhen openshift %}}

```yaml
[...]
ingress:
  enabled: true
  className: ""
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: mychart-<namespace>.<appdomain>
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: mychart-<namespace>
      hosts:
        -  mychart-<namespace>.<appdomain>
[...]
```

{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}

```yaml
[...]
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: mychart-<namespace>.<appdomain>
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: mychart-<namespace>-<appdomain>
      hosts:
        - mychart-<namespace>.<appdomain>
[...]
```

{{% /onlyWhenNot %}}

{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}
Therefore, we need to change this value inside our `values.yaml` file.

```yaml
...
ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: mychart-<namespace>.<appdomain>
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local
...
```

{{% /onlyWhen %}}

{{% alert title="Note" color="info" %}}
Make sure to set the proper value as hostname. `<appdomain>` will be provided by the trainer.
{{% onlyWhen mobi %}}
Use `<namespace>.<appdomain>` as your hostname. It might take some time until your ingress hostname is accessible, as the DNS name first has to be propagated correctly.
{{% /onlyWhen %}}
{{% /alert %}}

Apply the change by upgrading our release:

```bash
helm upgrade --namespace $USER myfirstrelease ./mychart
```

This will result in something similar to:

```
Release "myfirstrelease" has been upgraded. Happy Helming!
NAME: myfirstrelease
LAST DEPLOYED: Wed Dec  2 14:44:42 2020
NAMESPACE: <namespace>
STATUS: deployed
REVISION: 2
NOTES:
1. Get the application URL by running these commands:
  http://<namespace>.<appdomain>/
```

{{% onlyWhenNot customer %}}
Check whether the ingress was successfully deployed by accessing the URL `http://mychart-<namespace>.<appdomain>/`

{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}
Check whether the ingress was successfully deployed by accessing the URL `https://mychart-<namespace>.<appdomain>/`

{{% /onlyWhen %}}


## {{% task %}} Overwrite value using commandline param

An alternative way to set or overwrite values for charts we want to deploy is the `--set name=value` parameter. This parameter can be used when installing a chart as well as upgrading.

Update the replica count of your nginx Deployment to 2 using `--set name=value`


### Solution

```bash
helm upgrade --namespace $USER --set replicaCount=2 myfirstrelease ./mychart
```

Values that have been set using `--set` can be reset by helm upgrade with `--reset-values`.


## {{% task %}} Values

Have a look at the `values.yaml` file in your chart and study all the possible configuration params introduced in a freshly created chart.


## {{% task %}} Remove release

To remove an application, simply remove the Helm release with the following command:

```bash
helm uninstall myfirstrelease --namespace $USER
```

Do this with our deployed release. With `{{% param cliToolName %}} get pods --namespace $USER` you should no longer see your application Pod.
