---
title: "12.2 CLI Installation"
weight: 122
---

This guide shows you how to install the Helm CLI. Helm can be installed either from source or from pre-built binary releases.


## Helm v2 vs. v3

Helm recently got a big update to v3 which saw some significant changes. However, Helm v2 is still in heavy use. Before downloading any Helm cli client, make sure you get the correct version.

As for one of the big differences: Helm v2 requires a server-side component to be running inside your Kubernetes cluster called **Tiller**. Tiller is the service that actually communicates with the Kubernetes API to manage our Helm packages.

This implies that Tiller:

* will usually need admin privileges: If a user wants to install a chart that contains any cluster-wide element like a ClusterRole or a CustomResourceDefinition, Tiller should be privileged enough to create or delete those resources.
* should be accessible to any authenticated user: Any valid user of the cluster may require access to install a chart.

That leads to a now-obvious security issue: escalation of privileges. Suddenly, users with minimum privileges are able to interact with the cluster as if they were administrators. The problem is bigger if a Kubernetes pod gets compromised: that compromised pod is also able to access the cluster as an administrator. That's indeed disturbing.

With the v3 release, Helm got rid of Tiller.

{{% alert title="Tip" color="warning" %}}
Check out the [Helm Documentation](https://helm.sh/docs/topics/v2_v3_migration/) for more details about changes between v2 and v3.
{{% /alert %}}


## Install the Helm v3 CLI client

Every [release](https://github.com/helm/helm/releases) of Helm provides binary releases for a variety of OSes. These binary versions can be manually downloaded and installed.

The latest v3 release v3.1.2 can be found [here](https://github.com/helm/helm/releases/tag/v3.1.2).


## Task 1

Install the `helm` cli on your system:

1. Download your desired version from [here](https://get.helm.sh/helm-v3.1.2-linux-amd64.tar.gz)
1. Unpack it (`tar -zxvf helm-v3.1.2-linux-amd64.tar.gz`)
1. Find the helm binary in the unpacked directory and move it to its desired destination (e.g. `mv linux-amd64/helm /usr/local/bin/`)
    * The desired destination should be listed in your $PATH environment variable (`echo $PATH`)

{{% alert title="Windows Users" color="warning" %}}
Please make sure to select the [Windows version](https://get.helm.sh/helm-v3.1.2-windows-amd64.zip). Put the binary into your working directory or make sure the directory containing the `helm.exe` binary is in your `Path` environment variable.
{{% /alert %}}

To verify run the following command and check if `Version` is what you expected:

```bash
helm version
```

The output is similar to this:

```bash
version.BuildInfo{Version:"v3.1.2", GitCommit:"d878d4d45863e42fd5cff6743294a11d28a9abce", GitTreeState:"clean", GoVersion:"go1.13.8"}
```

From here you should be able to run the client and [add the stable repo](https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository):

```bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```
