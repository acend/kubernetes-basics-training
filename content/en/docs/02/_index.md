---
title: "2. Install the CLI"
weight: 2
sectionnumber: 2
---

In this lab, we will install and configure the `{{% param cliToolName %}}` client to be able to practice further tasks in the labs that follow.


## Command-line interface

The `{{% param cliToolName %}}` command is the primary command-line tool to work with one or several {{% param distroName %}} clusters.

As the client is written in Go, you can run the single binary on the following operating systems:

* Windows
* macOS
* Linux

{{< onlyWhen rancher >}}
{{% alert title="Note" color="primary" %}}
In Rancher you can also use `kubectl` directly within your browser. As soon as you are logged in in the Rancher web console, click on **Launch kubectl** (or use the ° key) and you get a console with `kubectl` installed and configured.
{{% /alert %}}
{{< /onlyWhen >}}

{{% onlyWhenNot openshift %}}


## Manual installation of kubectl

Follow <https://kubernetes.io/docs/tasks/tools/install-kubectl/>.

In case the installation from the official package repositories didn't work (or a specific version is needed) the static binary can be downloaded and put into one of the following paths.

Linux:

```
~/bin
```

macOS:

```
~/bin
```

Windows:

```
C:\Kubernetes\
```


## File modes on Linux and macOS

The `kubectl` has to be executable:

```bash
cd ~/bin
chmod +x kubectl
```


## PATH variable

In Linux and macOS the directory `~/bin` should already be part of the `PATH` variable.
In case `kubectl` is placed in a different directory, you can change the `PATH` variable with the following command:

```bash
export PATH=$PATH:[path to kubectl]
```


### Windows

The `PATH` can be set in Windows in the advanced system settings. It depends on the version:

* [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
* [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)
* [Windows 10](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/)
{{% /onlyWhenNot %}}

{{< onlyWhenNot openshift >}}
{{% alert title="Note: Windows Quick Hack" color="primary" %}}
Copy the `kubectl` binary directly into the folder `C:\Windows`.
{{% /alert %}}
{{< /onlyWhenNot >}}

{{% onlyWhen openshift %}}


## Installation of `oc`

The straight-forward way to installing `oc` on your system is to install by downloading the binary.
This is what we are going to do step by step.
Choose the tab appropriate to your operating system.


### Windows

1. First, download `oc`. The following URL directly points to the latest stable `oc` version:

   <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-windows.zip>

1. Unzip the downloaded archive with a ZIP program.
1. Move the `oc` binary to a directory that is on your `PATH`.

   {{% alert title="Note" color="primary" %}}
   To check your `PATH`, open the command prompt and execute the following command:

   ```
   C:\> path
   ```

   {{% /alert %}}


### macOS

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


### Linux

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
{{% /onlyWhen %}}


## Verify installation

You should now be able to execute `{{% param cliToolName %}}` in the command prompt. To test, execute:

```bash
{{% param cliToolName %}} version
```

You should now see something like (the version number may vary):

{{% onlyWhenNot openshift %}}

```
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
...
```

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}

```
Client Version: 4.5.7
...
```

{{% /onlyWhen %}}

If you don't see a similar output, possibly there are issues with the `PATH` variable.

{{% alert title="Warning" color="secondary" %}}
{{% onlyWhenNot openshift %}}
Make sure to use at least version 1.16.x for your `kubectl`
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Make sure to use at least `oc` version `4.5.x`.
{{% /onlyWhen %}}

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

{{% onlyWhen openshift %}}


## First steps with oc

The `oc` binary has many commands and sub-commands. Invoke `oc --help` to get a list of all commands; `oc <command> --help` gives you detailed help information about a command.

If you don't want to memorize all `oc` options then use the `oc` cheat sheet: <https://developers.redhat.com/cheat-sheets/red-hat-openshift-container-platform>


## Other tools to work with OpenShift

* [CodeReady Containers](https://developers.redhat.com/products/codeready-containers/overview)
* [CodeReady Workspaces](https://developers.redhat.com/products/codeready-workspaces/overview)
{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}


## First steps with kubectl

The `kubectl` binary has many commands and sub-commands. Invoke `kubectl -h` to get a list of all commands; `kubectl <command> -h` gives you detailed help about a command.

If you don't want to memorize all `kubectl` options then use the `kubectl` cheat sheet: <https://kubernetes.io/docs/reference/kubectl/cheatsheet/>


## Optional power tools for kubectl

`kubectx` and `kubens` are two handy shell scripts which let you easily switch between Kubernetes contexts and namespaces. See <https://github.com/ahmetb/kubectx> for detailed instructions.

Installation of `kubectx` and `kubens`:

```bash
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o ~/bin/kubectx
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o ~/bin/kubens
chmod +x ~/bin/kubectx ~/bin/kubens
```

`kube-ps1` is another helpful shell script which adds the current context and namespace to the shell prompt: <https://github.com/jonmosco/kube-ps1>

`fzf` is yet another handy helper tool when you have to deal with a lot of contexts or namespaces by adding an interactive menu to `kubectx`and `kubens`: <https://github.com/junegunn/fzf>

`stern` is a very powerful enhancement of `kubectl logs` and lets you tail logs of multiple containers and Pods at the same time: <https://github.com/wercker/stern>.


## Other tools to work with Kubernetes

* <https://github.com/lensapp/lens>
{{% /onlyWhenNot %}}
