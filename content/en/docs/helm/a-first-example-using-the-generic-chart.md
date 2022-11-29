---
title: "A first example using the Generic Chart"
weight: 124
onlyWhen: baloise
---

You're now all set to begin with a first example!


## {{% task %}} Create a `values.yaml` file

Still inside your `mychart` Helm Chart directory, open the already existing `values.yaml` file.
Inside you'll find a host of defined parameters. Delete them all.

Instead, fill in the following content:

```yaml
first-example-app:
  replicaCount: 1
  image:
    repository: REGISTRY-URL/example/nginx-sample
    tag: latest
    pullPolicy: IfNotPresent
  ingress:
    controller: Route
    clusterName: CLUSTER-NAME
  network:
    http:
      servicePort: 8080
      ingress:
        clusterName: CLUSTER-NAME
  readinessProbe:
    httpGet:
      path: /
      port: 8080
    initialDelaySeconds: 5
    timeoutSeconds: 1
  resources:
    requests:
      cpu: 10m
      memory: 16Mi
    limits:
      cpu: 200m
      memory: 32Mi
```


## {{% task %}} A first test

Before applying anything to the cluster, you should test if the current values have the desired effect.
In order to do so, execute the following command:

{{% alert title="Note" color="info" %}}
Don't forget to replace `<username>`.
{{% /alert %}}

```bash
helm template my-first-release-<username> .
```

Executing above command will output the rendered templates from the Generic Chart with the values you defined inside `values.yaml`.
Check what would be created and if the values are correct.


## {{% task %}} Install the chart

If you are satisfied with the output, install the release on the cluster:

{{% alert title="Note" color="info" %}}
Don't forget to replace `<username>` and `<namespace>`.
{{% /alert %}}

```bash
helm install my-first-release-<username> . --namespace <namespace>
```

You should get the following output:

```
NAME: my-first-release-<username>
LAST DEPLOYED: Tue Nov 22 16:40:01 2022
NAMESPACE: <namespace>
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Congratulations! You successfully deployed your first app using Helm!

You should now see a freshly created pod and a route inside your namespace.
Check the route's URL and open it in your browser.
A mountainous view and welcome message should greet you.
