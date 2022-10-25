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

The [Local installation](local-installation/) chapter explains how to locally install `{{% param cliToolName %}}` for the respective operating system.

If you're interested, also have a look at the {{<link "more-tools-to-work-with-openshift">}}, which is however totally optional.
{{% /onlyWhen %}}

{{% onlyWhenNot openshift %}}
Follow the instructions on the subsequent pages to complete the setup on your platform of choice.
{{% /onlyWhenNot %}}
