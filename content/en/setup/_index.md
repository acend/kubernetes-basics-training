---
title: "Setup"
weight: 1
type: docs
menu:
  main:
    weight: 1
---

## Setup instructions

This training depends on the installation of `{{% param cliToolName %}}`.

{{% onlyWhen openshift %}}
You have the choice of either using OpenShift's web terminal or installing `{{% param cliToolName %}}` locally.

If you prefer to not install anything on your computer, follow the instructions on the {{<link "web-terminal">}} page.

{{% onlyWhenNot baloise %}}
The [Local installation](local-installation/) chapter explains how to locally install `{{% param cliToolName %}}` for the respective operating system.

If you're interested, also have a look at the {{<link "more-tools-to-work-with-openshift">}}, which is however totally optional.
{{% /onlyWhenNot %}}
{{% onlyWhen baloise %}}
If you haven't done so already and wish to install `{{% param cliToolName %}}`, you should have received an email containing all the necessary information and references.
{{% /onlyWhen %}}
{{% /onlyWhen %}}

{{% onlyWhenNot openshift %}}
Follow the instructions on the subsequent pages to complete the setup on your platform of choice.
{{% /onlyWhenNot %}}

{{% alert title="Warning" color="warning" %}}
If you have already installed `{{% param cliToolName %}}`, please make sure you have an up-to-date version.
{{% /alert %}}
