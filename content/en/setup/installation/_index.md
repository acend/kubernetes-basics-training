---
title: "Installation"
weight: 1
---

## Command line tool

The `{{% param cliToolName %}}` command is the primary command line tool to work with one or several {{% param distroName %}} clusters.

As the client is written in Go, you can run the single binary on the following operating systems:

* Windows
* macOS
* Linux

{{% onlyWhen rancher %}}
{{% alert title="Note" color="info" %}}
In Rancher you can also use `kubectl` directly within your browser. As soon as you are logged in the Rancher web console, click on **Launch kubectl** (or use the ° key), and you get a console with `kubectl` installed and configured.
{{% /alert %}}
{{% /onlyWhen %}}
