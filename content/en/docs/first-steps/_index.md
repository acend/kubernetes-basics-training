---
title: "First steps"
weight: 2
---

In this lab, we will interact with the {{% param distroName %}} cluster for the first time.

{{% onlyWhenNot nosetup %}}
{{% alert title="Warning" color="warning" %}}
Please make sure you completed {{<link "setup">}} before you continue with this lab.
{{% /alert %}}
{{% /onlyWhenNot %}}
{{% onlyWhenNot openshift %}}


## Login

{{% alert title="Note" color="info" %}}
Authentication depends on the specific Kubernetes cluster environment. You may need special instructions if you are not using our lab environment. Details will be provided by your teacher.
{{% /alert %}}


## Namespaces


A Namespace is a logical design used in Kubernetes to organize and separate your applications, Deployments, Pods, Ingresses, Services, etc. on a top-level basis. Take a look at the [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). Authorized users inside a namespace are able to manage those resources. Namespace names have to be unique in your cluster.


### {{% task %}} Create a Namespace

{{% alert title="Note" color="info" %}}
If you work in our lab environment, your Namespace has already been created and you can skip this task.
{{% /alert %}}

Create a new namespace on the Kubernetes Cluster.. The `kubectl help` output can help you figure out the right command.

{{% alert title="Note" color="info" %}}
Please choose an identifying name for your Namespace, e.g. your initials or name as a prefix.

We are going to use `<namespace>` as a placeholder for your created Namespace.
{{% /alert %}}


### Solution

To create a new Namespace on your cluster use the following command:

```bash
kubectl create namespace <namespace>
```


{{% alert title="Note" color="info" %}}
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

Some prefer to explicitly select the Namespace for each `kubectl` command by adding `--namespace <namespace>` or `-n <namespace>`. Others prefer helper tools like `kubens` (see {{<link "05_kubernetes">}}).
{{% /alert %}}


{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}


## Projects

{{% onlyWhenNot baloise %}}
As a first step on the cluster, we are going to create a new Project.
{{% /onlyWhenNot %}}

A Project is a logical design used in OpenShift to organize and separate your applications, Deployments, Pods, Ingresses, Services, etc. on a top-level basis.
Authorized users inside a Project are able to manage those resources. Project names have to be unique in your cluster.


### {{% task %}} Create a Project

{{% onlyWhen baloise %}}
You would usually create your first Project here using `oc new-project`.
This is, however, not possible on the provided cluster.
Instead, a Project named `<username>-training` has been pre-created for you.
Use this Project for all labs in this training except for {{<link "resourcequotas-and-limitranges">}}.

{{% alert title="Note" color="info" %}}
Please inform your trainer if you don't see such a Project.
{{% /alert %}}
{{% /onlyWhen %}}

{{% onlyWhenNot baloise %}}
Create a new Project in the lab environment. The `oc help` output can help you figure out the right command.

{{% alert title="Note" color="info" %}}
Please choose an identifying name for your Project, e.g. your initials or name as a prefix. We are going to use `<namespace>` as a placeholder for your created Project.
{{% /alert %}}


### Solution

To create a new Project on your cluster use the following command:

```bash
oc new-project <namespace>
```

{{% /onlyWhenNot %}}

{{% alert title="Note" color="info" %}}
In order to declare what Project to use, you have several possibilities:

* Some prefer to explicitly select the Project for each `oc` command by adding `--namespace <namespace>` or `-n <namespace>`
* By using the following command, you can switch into another Project instead of specifying it for each `oc` command

```bash
oc project <namespace>
```

{{% /alert %}}


## {{% task %}} Discover the OpenShift web console

Discover the different menu entries in the two views, the **Developer** and the **Administrator** view.

Display all existing Pods in the previously created Project with `oc` (there shouldn't yet be any):

```bash
oc get pod --namespace <namespace>
```

{{% alert title="Note" color="info" %}}
With the command `oc get` you can display all kinds of resources.
{{% /alert %}}
{{% /onlyWhen %}}
