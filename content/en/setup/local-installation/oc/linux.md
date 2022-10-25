---
title: "Linux"
weight: 13
type: docs
onlyWhen: openshift
---

## Installation for Linux

The straight-forward way to installing `oc` on your system is to install by downloading the binary.
This is what we are going to do step by step:

1. First, download `oc`. The following URL directly points to the latest stable `oc` version:

   <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz>

1. Change into the directory in which you downloaded the file. Unpack the archive:

   ```bash
   tar xvzf openshift-client-linux.tar.gz
   ```

1. Place the `oc` binary in a directory that is on your `PATH`.

   {{% alert title="Note" color="info" %}}
   To check your `PATH`, execute the following command:

   ```
   echo $PATH
   ```

   {{% /alert %}}

1. If you have previously accessed a Kubernetes cluster you have to rename your `.kube` directory.

   Check if you have a directory `~\.kube` and rename it to something like `~\.kube_backup`.
   You can undo this after the training.


## Completion for Bash and Zsh (optional)

You can activate Bash completion:

```bash
source <({{% param cliToolName %}} completion bash)
```

As well as for Zsh:

```bash
source <({{% param cliToolName %}} completion zsh)
```

To make it permanent, you can put that command in your Bash configuration file:

```bash
echo "source <({{% param cliToolName %}} completion bash)" >> ~/.bashrc
```

On most Linux systems, you have to install the `bash-completion` package to make the completion work.

Debian/Ubuntu:

```bash
sudo apt install bash-completion
```

Fedora:

```bash
sudo dnf install bash-completion
```


## Verification

Now, verify your installation in {{<link "verification">}}.
