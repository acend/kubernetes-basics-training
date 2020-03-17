---
title: "1.0 - Install Helm CLI"
weight: 10
---

This guide shows how to install the Helm CLI. Helm can be installed either from source, or from pre-built binary releases.

### From the binary release

Every [release](https://github.com/helm/helm/releases) of Helm provides binary releases for a variety of OSes. These binary versions can be manually downloaded and installed.

1. Download your desired version
2. Unpack it (`tar -zxvf helm-v3.0.0-linux-amd64.tar.gz`)
3. Find the helm binary in the unpacked directory, and move it to its desired destination (`mv linux-amd64/helm /usr/local/bin/helm`)

From there, you should be able to run the client and [add the stable repo](https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository): `helm help`.


{{% notice tip %}}

SAMPLE Note

{{% /notice %}}

{{% collapse solution-1 "Solution 1" %}}

SAMPLE Collapse

{{% /collapse %}}


### Helm v2 vs v3



### Tiller

