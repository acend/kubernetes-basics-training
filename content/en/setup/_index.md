---
title: "Setup"
weight: 2
type: docs
menu:
  main:
    weight: 1
---

## Command line tool

The `{{% param cliToolName %}}` command is the primary command line tool to work with one or several {{% param distroName %}} clusters.

As the client is written in Go, you can run the single binary on the following operating systems:

* Windows
* macOS
* Linux

{{% onlyWhen rancher %}}
{{% alert title="Note" color="primary" %}}
In Rancher you can also use `kubectl` directly within your browser. As soon as you are logged in the Rancher web console, click on **Launch kubectl** (or use the ° key), and you get a console with `kubectl` installed and configured.
{{% /alert %}}
{{% /onlyWhen %}}


## Setup introduction

This training depends on the installation of `{{% param cliToolName %}}`.
Follow the instructions on the subsequent pages to complete the setup on your platform of choice.
