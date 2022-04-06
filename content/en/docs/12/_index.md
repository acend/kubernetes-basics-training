---
title: "12. Kustomize"
weight: 12
sectionnumber: 12
onlyWhenNot: techlab
---


[Kustomize](https://kustomize.io/) is a tool to manage YAML configurations for Kubernetes objects in a declarative and reusable manner. In this lab, we will use Kustomize to deploy the same app for two different environments.


## Installation

Kustomize can be used in two different ways:

* As a standalone `kustomize` binary, downloadable from [here](https://kubernetes-sigs.github.io/kustomize/installation/)
* With the parameter `--kustomize` or `-k` in certain `{{% param cliToolName %}}` subcommands such as `apply` or `create`

{{% alert title="Note" color="info" %}}
You might get a different behaviour depending on which variant you use. The reason for this is that the version built into `{{% param cliToolName %}}` is usually older than the standalone binary.
{{% /alert %}}


## Usage

The main purpose of Kustomize is to build configurations from a predefined file structure (which will be introduced in the next section):

```bash
kustomize build <dir>
```

The same can be achieved with `{{% param cliToolName %}}`:

```bash
{{% param cliToolName %}} kustomize <dir>
```

The next step is to apply this configuration to the {{% param distroName %}} cluster:

```bash
kustomize build <dir> | {{% param cliToolName %}} apply -f -
```

Or in one `{{% param cliToolName %}}` command with the parameter `-k` instead of `-f`:

```bash
{{% param cliToolName %}} apply -k <dir>
```


## Task {{% param sectionnumber %}}.1: Prepare a Kustomize config

We are going to deploy a simple application:

* The Deployment starts an application based on nginx
* A Service exposes the Deployment
* The application will be deployed for two different example environments, integration and production

Kustomize allows inheriting Kubernetes configurations. We are going to use this to create a base configuration and then override it for the different environments.
Note that Kustomize does not use templating. Instead, smart patch and extension mechanisms are used on plain YAML manifests to keep things as simple as possible.


### File structure

The structure of a Kustomize configuration typically looks like this:

```text
.
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays
    ├── production
    │   ├── deployment-patch.yaml
    │   ├── kustomization.yaml
    │   └── service-patch.yaml
    └── staging
        ├── deployment-patch.yaml
        ├── kustomization.yaml
        └── service-patch.yaml
```


### Base

Let's have a look at the `base` directory first which contains the base configuration. There's a `deployment.yaml` with the following content:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/base/deployment.yaml" >}}{{< /highlight >}}

There's also a Service for our Deployment in the corresponding `base/service.yaml`:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/base/service.yaml" >}}{{< /highlight >}}

And there's an additional `base/kustomization.yaml` which is used to configure Kustomize:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/base/kustomization.yaml" >}}{{< /highlight >}}

It references the previous manifests `service.yaml` and `deployment.yaml` and makes them part of our base configuration.


### Overlays

Now let's have a look at the other directory which is called `overlays`. It contains two subdirectories `staging` and `production` which both contain a `kustomization.yaml` with almost the same content.

`overlays/staging/kustomization.yaml`:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/overlays/staging/kustomization.yaml" >}}{{< /highlight >}}

`overlays/production/kustomization.yaml`:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/overlays/production/kustomization.yaml" >}}{{< /highlight >}}

Only the first key `nameSuffix` differs.

In both cases, the `kustomization.yaml` references our base configuration. However, the two directories contain two different `deployment-patch.yaml` files which patch the `deployment.yaml` from our base configuration.

`overlays/staging/deployment-patch.yaml`:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/overlays/staging/deployment-patch.yaml" >}}{{< /highlight >}}

`overlays/production/deployment-patch.yaml`:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/overlays/production/deployment-patch.yaml" >}}{{< /highlight >}}

The main difference here is that the environment variable `APPLICATION_NAME` is set differently. The `app` label also differs because we are going to deploy both Deployments into the same Namespace.

The same applies to our Service. It also comes in two customizations so that it matches the corresponding Deployment in the same Namespace.

`overlays/staging/service-patch.yaml`:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/overlays/staging/service-patch.yaml" >}}{{< /highlight >}}

`overlays/production/service-patch.yaml`:

{{< highlight yaml >}}{{< readfile file="content/en/docs/12/kustomize/overlays/production/service-patch.yaml" >}}{{< /highlight >}}

{{% alert title="Note" color="info" %}}
All files mentioned above are also directly accessible from [GitHub](https://github.com/acend/kubernetes-basics-training/tree/master/content/en/docs/12/kustomize).
{{% /alert %}}

Prepare the files as described above in a local directory of your choice.


## Task {{% param sectionnumber %}}.2: Deploy with Kustomize

We are now ready to deploy both apps for the two different environments. For simplicity, we will use the same Namespace.

```bash
{{% param cliToolName %}} apply -k overlays/staging --namespace <namespace>
```

```
service/kustomize-app-staging created
deployment.apps/kustomize-app-staging created
```

```bash
{{% param cliToolName %}} apply -k overlays/production --namespace <namespace>
```

```bash
service/kustomize-app-production created
deployment.apps/kustomize-app-production created
```

As you can see, we now have two deployments and services deployed. Both of them use the same base configuration.
However, they have a specific configuration on their own as well.

Let's verify this. Our app writes a corresponding log entry that we can use for analysis:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

```
NAME                                       READY   STATUS    RESTARTS   AGE
kustomize-app-production-74c7bdb7d-8cccd   1/1     Running   0          2m1s
kustomize-app-staging-7967885d5b-qp6l8     1/1     Running   0          5m33s
```

```bash
{{% param cliToolName %}} logs kustomize-app-staging-7967885d5b-qp6l8
```

```
My name is kustomize-app-staging
```

```bash
{{% param cliToolName %}} logs kustomize-app-production-74c7bdb7d-8cccd
```

```
My name is kustomize-app-production
```


## Further information

Kustomize has more features of which we just covered a couple. Please refer to the docs for more information.

* Kustomize documentation: <https://kubernetes-sigs.github.io/kustomize/>
* API reference: <https://kubernetes-sigs.github.io/kustomize/api-reference/>
* Another `kustomization.yaml` reference: <https://kubectl.docs.kubernetes.io/pages/reference/kustomize.html>
* Examples: <https://github.com/kubernetes-sigs/kustomize/tree/master/examples>
