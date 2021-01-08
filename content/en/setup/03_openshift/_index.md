---
title: "Installation for Linux"
weight: 3
type: docs
sectionnumber: 1
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

   {{% alert title="Note" color="primary" %}}
   To check your `PATH`, execute the following command:

   ```
   echo $PATH
   ```

   {{% /alert %}}


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

Now, [verify your installation](../04/).
