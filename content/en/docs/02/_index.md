---
title: "2. First steps"
weight: 2
sectionnumber: 2
---

In this lab, we will interact with the {{% param distroName %}} cluster for the first time.

{{% alert title="Warning" color="secondary" %}}
Please make sure you completed [lab 1](../01/) before you continue with this lab.
{{% /alert %}}


## Login

{{% onlyWhenNot openshift %}}
{{% alert title="Note" color="primary" %}}
Authentication depends on the specific Kubernetes cluster environment.

You may need special instructions if you are not using our lab environment.
{{% /alert %}}
{{% /onlyWhenNot %}}

{{% onlyWhenNot openshift %}}
{{% onlyWhen rancher %}}
{{% onlyWhenNot mobi %}}
Our Kubernetes cluster of the lab environment runs on [cloudscale.ch](https://cloudscale.ch) (a Swiss IaaS provider) and has been provisioned with [Rancher](https://rancher.com/). You can log in to the cluster with a Rancher user.

{{% alert title="Note" color="primary" %}}
Your teacher will provide you with the credentials to log in.
{{% /alert %}}
{{% /onlyWhenNot %}}

Log in to the Rancher web console and choose the desired cluster.

You now see a button at the top right that says **Kubeconfig File**. Click it, scroll down to the bottom and click **Copy to Clipboard**.

![Download kubeconfig File](kubectlconfigfilebutton.png)

The copied kubeconfig now needs to be put into a file. The default location for the kubeconfig file is `~/.kube/config`.

{{% alert title="Note" color="primary" %}}
If you already have a kubeconfig file, you might need to merge the Rancher entries with yours. Or use a dedicated file as described below.
{{% /alert %}}

Put the copied content into a kubeconfig file on your system.
If you decide to not use the default kubeconfig location at `~/.kube/config` then let `kubectl` know where you put it with the KUBECONFIG environment variable:

```
export KUBECONFIG=$KUBECONFIG:~/.kube-techlab/config
```

{{% alert title="Note" color="primary" %}} When using PowerShell on a Windows Computer use the following command, you'll have to replace `<user>` with your actual user

```
$Env:KUBECONFIG = "C:\Users\<user>\.kube-techlab\config"
```

To set the environment variable (`KUBECONFIG` = `C:\Users\<user>\.kube-techlab\config`) permenantly, check the following documentation:

The `PATH` can be set in Windows in the advanced system settings. It depends on the version:

* [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
* [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)
* [Windows 10](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/)

{{% /alert %}}

{{% /onlyWhen %}}

{{% onlyWhen mobi %}}
We are using the Mobi `kubedev` Kubernetes cluster. Use the following command to set the appropriate context:

```bash
kubectl config use-context kubedev
```

{{% alert title="Warning" color="secondary" %}}
Make sure you have setup your kubeconfig file correctly. Check your [CWIKI](https://cwiki.mobicorp.ch/confluence/display/ITContSol/Set+up+Kubectl) for instructions on how to configure it.
{{% /alert %}}
{{% /onlyWhen %}}


## Namespaces

As a first step on the cluster we are going to create a new Namespace.

A Namespace is the logical design used in Kubernetes to organize and separate your applications, Deployments, Pods, Ingresses, Services, etc. on a top-level basis. Take a look at the [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). Authorized users inside a namespace are able to manage those resources. Namespace names have to be unique in your cluster.

{{% onlyWhen rancher %}}
{{% alert title="Note" color="primary" %}}
Additionally, Rancher knows the concept of a [*Project*](https://rancher.com/docs/rancher/v2.x/en/cluster-admin/projects-and-namespaces/) which encapsulates multiple Namespaces.
{{% /alert %}}

In the Rancher web console choose the Project called `techlab`.

{{% onlyWhen mobi %}}
We use the project `kubernetes-techlab` on the `kubedev` cluster.
{{% /onlyWhen %}}

{{% onlyWhenNot mobi %}}
![Rancher Project](chooseproject.png)
{{% /onlyWhenNot %}}

{{% /onlyWhen %}}


### Task {{% param sectionnumber %}}.1: Create a Namespace

Create a new namespace in the lab environment. The `kubectl help` output can help you figure out the right command.

{{% alert title="Note" color="primary" %}}
Please choose an identifying name for your Namespace, e.g. your initials or name as a prefix.

We are going to use `<namespace>` as a placeholder for your created Namespace.
{{% /alert %}}


### Solution

To create a new Namespace on your cluster use the following command:

```bash
kubectl create namespace <namespace>
```

{{% onlyWhen rancher %}}
{{% alert title="Note" color="primary" %}}
Namespaces created via `kubectl` have to be assigned to the correct Rancher Project in order to be visible in the Rancher web console. Please ask your teacher for this assignment. Or you can create the Namespace directly within the Rancher web console.
{{% /alert %}}
{{% /onlyWhen %}}

{{% alert title="Note" color="primary" %}}
By using the following command, you can switch into another Namespace instead of specifying it for each `kubectl` command.

Linux:

```bash
kubectl config set-context $(kubectl config current-context) --namespace <namespace>
```

Windows:

```bash
kubectl config current-context
SET KUBE_CONTEXT=[Insert output of the upper command]
kubectl config set-context %KUBE_CONTEXT% --namespace <namespace>
```

Some prefer to explicitly select the Namespace for each `kubectl` command by adding `--namespace <namespace>` or `-n <namespace>`. Others prefer helper tools like `kubens` (see [lab 2](../02/)).
{{% /alert %}}

{{% onlyWhen rancher %}}


## Task {{% param sectionnumber %}}.2: Discover the Rancher web console

Check the menu entries, there should neither appear any Deployments nor any Pods or Services in your Namespace.

Display all existing Pods in the previously created Namespace with `kubectl` (there shouldn't yet be any):

```bash
kubectl get pod -n <namespace>
```

With the command `kubectl get` you can display all kinds of resources.
{{% /onlyWhen %}}
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}


### Login on the Web Console

{{% alert title="Note" color="primary" %}}
Your teacher will provide you with the credentials to log in.
{{% /alert %}}

Open your browser, open the OpenShift cluster URL and log in using the provided credentials.


### Login in the shell

In order to log in on the shell, you can copy the login command from the Web Console and then paste it on the shell.

To do that, open the Web Console and click on your username you see at the top right, then choose **Copy Login Command**.

![oc-login](login-ocp.png)

A new tab or window opens in your browser.

{{% alert title="Note" color="primary" %}}
You might need to login again.
{{% /alert %}}

The page now displays a link **Display token**.
Click it and copy the command under **Log in with this token**.

Now paste the copied command in your shell.


### Verify login

If you now execute `oc version` you should see something like this (version numbers may vary):

```
Client Version: 4.5.7
Server Version: 4.5.7
Kubernetes Version: v1.18.3+2cf11e2
```


## Projects

As a first step on the cluster we are going to create a new Project.

A Project is the logical design used in OpenShift to organize and separate your applications, Deployments, Pods, Ingresses, Services, etc. on a top-level basis.
Authorized users inside a Project are able to manage those resources. Project names have to be unique in your cluster.


### Task {{% param sectionnumber %}}.1: Create a Project

Create a new Project in the lab environment. The `oc help` output can help you figure out the right command.

{{% alert title="Note" color="primary" %}}
Please choose an identifying name for your Project, e.g. your initials or name as a prefix. We are going to use `<project>` as a placeholder for your created Project.
{{% /alert %}}


### Solution

To create a new Project on your cluster use the following command:

```bash
oc new-project <project>
```

{{% alert title="Note" color="primary" %}}
Some prefer to explicitly select the Project for each `oc` command by adding `--namespace <project>` or `-n <project>`.

By using the following command, you can switch into another Project instead of specifying it for each `oc` command.

```bash
oc project <project>
```

{{% /alert %}}


## Task {{% param sectionnumber %}}.2: Discover the OpenShift web console

Discover the different menu entries in the two views, the **Developer** and the **Administrator** view.

Display all existing Pods in the previously created Project with `oc` (there shouldn't yet be any):

```bash
oc get pod --namespace <project>
```

{{% alert title="Note" color="primary" %}}
With the command `oc get` you can display all kinds of resources.
{{% /alert %}}
{{% /onlyWhen %}}
