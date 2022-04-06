---
title: "Installation for Windows"
weight: 3
type: docs
sectionnumber: 1
onlyWhenNot: openshift
---

## Installation for Windows

Follow the steps outlined in <https://kubernetes.io/docs/tasks/tools/install-kubectl/>.

In case the installation from the official package repositories didn't work (or a specific version is needed) the static binary can be downloaded and put into the following path:

```
C:\Kubernetes\
```

In Windows, the `PATH` can be set in the advanced system settings. It depends on the version:

* [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
* [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)
* [Windows 10](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/)

{{% alert title="Note: Windows Quick Hack" color="info" %}}
Copy the `kubectl` binary directly into the folder `C:\Windows`.
{{% /alert %}}


## Verification

Now, [verify your installation](../04/).
