---
title: "2.0 - Install the Kubernetes CLI"
weight: 20
---


# Lab 2: Install the Kubernetes CLI

In this we will install and configure the `kubectl` client to be able to practice on further tasks in the following techlabs.

**Note:** In Rancher you can use `kubectl` directly within your browser. As soon as you are loggend in Rancher WebGUI, click on "Launch kubectl" (or use the ° key) and you get a console with kubectl installed and configured.

## Command Line Interface

`kubectl` provides for you a console based interface to control one or several Kubernetes clusters.

As the client is written in Go, you can run the single binary on the following Operating Systems:

- Microsoft Windows
- Mac OS X
- Linux

## Manual installation of `kubectl`

Follow https://kubernetes.io/docs/tasks/tools/install-kubectl/

In case the installation from the official package repositories didn't work or a specific version is need, the static binary can be downloaded and put into one of the following paths.

**Linux**

```
~/bin
```

**Mac OS X**

```
~/bin
```

**Windows**

```
C:\Kubernetes\
```


## Set the the right file modes on Linux and MacOS

`kubectl` has to be executable:

```
cd ~/bin
chmod +x kubectl
```


## `kubectl` folder in PATH variable

In **Linux** and **Mac OS X** the directory _~/bin_ should already be part of the PATH variable.
In case `kubectl` is placed in a different directory, you can change the PATH with the following command:

```
$ export PATH=$PATH:[path to kubectl]
```


### Windows

The PATH can be set in windows in the advanced system settings. It depends on the used version:

- [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
- [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)
- [Windows 10](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/)

**Windows Quick Hack**

Copy the `kubectl` binary directly into the folder `C:\Windows`.


## Verify installation 

The `kubectl` binary should be correctly installed by now. This can be proofed by running the following command:

```
$ kubectl version
```

The shown output should look similar to this:

```
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
[...]
```

If you don't see a similar out, possibly there are issues with the set PATH variable.

---

## bash/zsh completion (optional)

Running on Linux and iOS (Mac) you can activate the bash completion:

```
source <(kubectl completion bash)
```

As well as for zsh:
```
source <(kubectl completion zsh)
```

To make it permanent you can put that command in our bash configuration file:

```
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

On most linux systems you have to install the bash-completion packet to make the completion work.

Ubuntu:

```
sudo apt install bash-completion
```
## First steps with kubectl

`kubectl` has many commands and subcommands. Invoke `kubectl [-h]` to get a list of all commands; `kubectl <command> -h`
gives you detailed help about a command.

If you don't want to memorize all `kubectl` options then use the `kubectl` Cheat Sheet: 
<https://kubernetes.io/docs/reference/kubectl/cheatsheet/>

## Optional power tools for kubectl

`kubectx` and `kubens` are two handy shell scripts which let you easily switch between Kubernetes contexts and
namespaces. See <https://github.com/ahmetb/kubectx> for detailed instructions.

Installation of `kubectx` and `kubens`:

```
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o ~/bin/kubectx
curl https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o ~/bin/kubens
chmod +x ~/bin/kubectx ~/bin/kubens
```

`kube-ps1` is another helpful shell script which adds the current context and namespace to the shell prompt: 
<https://github.com/jonmosco/kube-ps1>

`fzf` is yet another handy helper tool when you have to deal with a lot of contexts or namespaces by 
adding an interactive menu to `kubectx`and `kubens`: <https://github.com/junegunn/fzf>

`stern` is a very powerful enhancement of `kubectl logs` and lets you tail logs of multiple containers and pods at the 
same time: <https://github.com/wercker/stern>. 

---

**End of lab 2**