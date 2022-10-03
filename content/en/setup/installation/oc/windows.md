---
title: "Windows"
weight: 3
type: docs
onlyWhen: openshift
---

## Installation for Windows

The straight-forward way to installing `oc` on your system is to install by downloading the binary.
This is what we are going to do step by step:

1. First, download `oc`. The following URL directly points to the latest stable `oc` version:

   <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-windows.zip>

1. Unzip the downloaded archive with a ZIP program.
1. Move the `oc` binary to a directory that is on your `PATH`.

   {{% alert title="Note" color="info" %}}
   To check your `PATH`, open the command prompt and execute the following command:

   ```
   C:\> path
   ```

   {{% /alert %}}

1. If you have previously accessed a Kubernetes cluster you have to rename your `.kube` directory.

   Check if you have a directory `%HOMEPATH%\.kube` and rename it to something like `%HOMEPATH%\.kube_backup`.
   You can undo this after the training.

1. Now, verify your installation in {{<link "verify-the-installation">}}.
