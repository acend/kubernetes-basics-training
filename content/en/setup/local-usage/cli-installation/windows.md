---
title: "Windows"
weight: 11
type: docs
---

## Installation for Windows

{{% onlyWhenNot openshift %}}

Follow the steps outlined in <https://kubernetes.io/docs/tasks/tools/install-kubectl/>.

In case the installation from the official package repositories didn't work (or a specific version is needed) the static binary can be downloaded and put into the following path:

```
C:\Kubernetes\
```

In Windows, the `PATH` can be set in the advanced system settings. It depends on the version:

* [Windows 10](https://www.thewindowsclub.com/how-to-add-edit-a-path-variable-in-windows)
* [Windows 11](https://thecategorizer.com/windows/how-to-add-path-and-environment-variables-in-windows/)

{{% alert title="Note: Windows Quick Hack" color="info" %}}
Copy the `kubectl` binary directly into the folder `C:\Windows`.
{{% /alert %}}


### Verification

Now, verify your installation in {{<link "verification">}}.

{{% /onlyWhenNot %}}

{{% onlyWhen openshift %}}

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

1. Now, head over to the {{<link "console-login">}} page.

{{% /onlyWhen %}}
