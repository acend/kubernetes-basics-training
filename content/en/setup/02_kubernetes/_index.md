---
title: "Installation for Mac"
weight: 4
type: docs
sectionnumber: 1
onlyWhenNot: openshift
---

## Installation for Mac

Follow the steps outlined in <https://kubernetes.io/docs/tasks/tools/install-kubectl/>.

In case the installation from the official package repositories didn't work (or a specific version is needed) the static binary can be downloaded and put into the following path:

```
~/bin
```


## File mode

The `kubectl` binary has to be executable:

```bash
cd ~/bin
chmod +x kubectl
```


## PATH variable

In macOS, the directory `~/bin` should already be part of the `PATH` variable.
In case `kubectl` is placed in a different directory, you can change the `PATH` variable with the following command:

```bash
export PATH=$PATH:[path to kubectl]
```


## Verification

Now, [verify your installation](../04/).
