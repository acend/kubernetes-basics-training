---
title: "Setup"
weight: 1
type: docs
menu:
  main:
    weight: 1
---

## Setup instructions

This training depends on `{{% param cliToolName %}}`, the {{% param distroName %}} command-line interface.

{{% onlyWhen openshift %}}
You have the choice of either using OpenShift's web terminal or installing `{{% param cliToolName %}}` locally.

If you prefer to not install anything on your computer, follow the instructions on the {{<link "web-terminal">}} page.

The {{<link "local-usage">}} chapter explains how to install `{{% param cliToolName %}}` for the respective operating system.

Also have a look at the {{<link "more-tools-to-work-with-openshift">}}, which is, however, totally optional.
{{% /onlyWhen %}}

{{% onlyWhenNot openshift %}}
Follow the instructions on the subsequent pages to complete the setup on your platform of choice.
{{% /onlyWhenNot %}}

{{% alert title="Warning" color="warning" %}}
In case you've already installed `{{% param cliToolName %}}`, please make sure you have an up-to-date version.
{{% /alert %}}
