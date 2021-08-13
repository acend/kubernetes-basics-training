---
title: "11.2 CLI Installation"
weight: 112
sectionnumber: 11.2
---

This guide shows you how to install the `helm` CLI tool. `helm` can be installed either from source or from pre-built binary releases.
We are going to use the pre-built releases.
`helm` binaries can be found on [Helm's release page](https://github.com/helm/helm/releases) for the usual variety of operating systems.


## Task {{% param sectionnumber %}}.1: Install CLI

Install the CLI for your **Operating System**

1. [Download the latest release](https://github.com/helm/helm/releases)
1. Unpack it (e.g. `tar -zxvf <filename>`)
1. Copy to the correct location
   * Linux: Find the `helm` binary in the unpacked directory and move it to its desired destination (e.g. `mv linux-amd64/helm ~/.local/bin/`)
     * The desired destination should be listed in your $PATH environment variable (`echo $PATH`)
   * macOS: Find the `helm` binary in the unpacked directory and move it to its desired destination (e.g. `mv darwin-amd64/helm ~/bin/`)
     * The desired destination should be listed in your $PATH environment variable (`echo $PATH`)
   * Windows: Find the `helm` binary in the unpacked directory and move it to its desired destination
     * The desired destination should be listed in your $PATH environment variable (`echo $PATH`)

{{% onlyWhen mobi %}}


## Proxy configuration

{{% alert title="Note" color="primary" %}}
If you have direct access to the internet from your location, the proxy configuration is not required.
{{% /alert %}}

Set your HTTP proxy environment variables so that a chart repository can be added to your Helm repos in a later lab:

```bash
export HTTP_PROXY="http://<username>:<password>@dirproxy.mobi.ch:80"
export HTTPS_PROXY="http://<username>:<password>@dirproxy.mobi.ch:80"
export NO_PROXY="localhost,127.0.0.1,.mobicorp.ch,.mobicorp.test,.mobi.ch"
```

Replace `<username`> and `<password>` with your credentials. If you have special characters in your password, escape them with their corresponding hexadecimal values according to [this article](https://en.wikipedia.org/wiki/Percent-encoding#Percent-encoding_reserved_characters).
{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.2: Verify

To verify, run the following command and check if `Version` is what you expected:

```bash
helm version
```

The output is similar to this:

```bash
version.BuildInfo{Version:"v3.5.3", GitCommit:"041ce5a2c17a58be0fcd5f5e16fb3e7e95fea622", GitTreeState:"dirty", GoVersion:"go1.15.8"}
```

From here on you should be able to run the client.
