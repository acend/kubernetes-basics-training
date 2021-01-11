---
title: "Installation for macOS"
weight: 4
type: docs
sectionnumber: 1
onlyWhen: openshift
---

## Installation for macOS

The straight-forward way to installing `oc` on your system is to install by downloading the binary.
This is what we are going to do step by step.

{{% alert title="Note" color="primary" %}}
With Homebrew, use `brew install openshift-cli`.
{{% /alert %}}

1. First, download `oc`. The following URL directly points to the latest stable `oc` version:

   <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-mac.tar.gz>

1. Change into the directory in which you downloaded the file. Unpack the archive, e.g. with:

   ```bash
   tar xvzf openshift-client-mac.tar.gz
   ```

1. Place the `oc` binary in a directory that is on your `PATH`.

   {{% alert title="Note" color="primary" %}}
   To check your `PATH`, execute the following command:

   ```
   echo $PATH
   ```

   {{% /alert %}}

1. [Verify your installation](../04/).
