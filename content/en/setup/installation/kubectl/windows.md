---
title: "Installation for Windows"
weight: 3
type: docs
onlyWhenNot: openshift
---

## Installation for Windows

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


## Verification

Now, [verify your installation](../04/).
