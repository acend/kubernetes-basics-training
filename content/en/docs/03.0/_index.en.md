---
title: "3. First steps in the lab environment"
weight: 3
sectionnumber: 3
---


In this lab, we will interact for the first time with the Kubernetes cluster.

{{% alert title="Warning" color="secondary" %}}
Please make sure you completed [lab 2](../02.0/) before you continue with this lab.
{{% /alert %}}


## Login and choose a Kubernetes cluster

{{% alert title="Note" color="primary" %}}
Authentication depends on the specific Kubernetes cluster environment. You may need special instructions if you're not
using our lab environment.
{{% /alert %}}

{{< onlyWhen rancher >}}
{{< onlyWhenNot mobi >}}
Our Kubernetes cluster of the lab environment runs on [cloudscale.ch](https://cloudscale.ch) (a swiss IaaS Provider) and has been provisioned with [Rancher](https://rancher.com/). You can login into the cluster with a Rancher user.

{{% alert title="Note" color="primary" %}}
For details about your credentials to log in, ask your teacher.
{{% /alert %}}

Login into the Rancher WebGUI choose the desired cluster.

On the cluster dashboard you find top right a button with `Kubeconfig File`. Save the config file into your homedirectory `.kube/config`. Verify afterwards if `kubectl` works correctly e.g. with `kubectl version`

![Download Kubeconfig File](kubectlconfigfilebutton.png)

{{% alert title="Note" color="primary" %}}
If you already have a kubeconfig file, you might need to merge the Rancher entries with yours. Or use the KUBECONFIG environment variable to specify a dedicated file.
{{% /alert %}}

```
#example location ~/.kube-techlab/config
vim ~/.kube-techlab/config
# paste content

# set KUBECONFIG Environment Variable to the correct file
export KUBECONFIG=$KUBECONFIG:~/.kube-techlab/config
```

{{< /onlyWhenNot >}}
{{< /onlyWhen >}}

{{< onlyWhen mobi >}}
We are using the Mobi `kubedev` Kubrnets Cluster. With:

```bash
kubectl config use-context dev
```

you choose the correct kubernetes cluster to work with.

{{% alert title="Warning" color="secondary" %}}
Make sure you have setup your `kube.config` file correctly. Check your [CWIKI](https://cwiki.mobicorp.ch/confluence/display/ITContSol/Set+up+Kubectl) for instructions on how to configure the cli client.
{{% /alert %}}
{{< /onlyWhen >}}


## Namespaces

As a first step we are going to create a new namespace.

A namespace is the logical design used in Kubernetes to organize and separate your applications, Deployments, Pods, Ingresses, Services, etc., on a top-level basis. Take a look at the [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). Authorized users inside a namespace are able to manage those resources. Namespace names have to be unique in your cluster.

{{< onlyWhen rancher >}}
{{% alert title="Note" color="primary" %}}
Additionally, Rancher does know the concept of a [project](https://rancher.com/docs/rancher/v2.x/en/cluster-admin/projects-and-namespaces/) which encapsulates multiple namespaces.
{{% /alert %}}

In the Rancher WebGUI you can now choose your Project.

{{< onlyWhen mobi >}}
We use the project `kubernetes-techlab` on the `kubedev` cluster.
{{< /onlyWhen >}}

{{< onlyWhenNot mobi >}}
![Rancher Project](chooseproject.png)
{{< /onlyWhenNot >}}

{{< /onlyWhen >}}


### Task {{% param sectionnumber %}}.1: Create a Namespace

How can a new namespace be created? The `kubectl` can help you to figure out the right commands:

```bash
kubectl help
```

{{% alert title="Note" color="primary" %}}
Please choose an identifying name for the namespace, in best case your abbreviation. We are going to use `<namespace>` as a placeholder for your created namespace.
{{% /alert %}}


### Solution

To create a new namespace on your cluster use the following command:

```bash
kubectl create namespace <namespace>
```

{{< onlyWhen rancher >}}
{{% alert title="Note" color="primary" %}}
Namespaces created via `kubectl`, have to be assigned to your Rancher project in order to be seen inside the Rancher WebGUI. Ask your teacher for the assignement. Or you can create the namespace directlly within the Rancher WebGui
{{% /alert %}}
{{< /onlyWhen >}}


{{% alert title="Note" color="primary" %}}
By using the following command, you can switch into another namespace instead of specifying the namespace for each `kubectl` command:

```bash
# Linux:
kubectl config set-context $(kubectl config current-context) --namespace <namespace>
```

Windows:

```bash
kubectl config current-context
// Save the context in a variable
SET KUBE_CONTEXT=[Insert output of the upper command]
kubectl config set-context %KUBE_CONTEXT% --namespace <namespace>
```

Some prefer to explicitly select the namespace for each `kubectl` command by adding `--namespace <namespace>`
or `-n <namespace>`. And others prefer helper tools like `kubens`, see [lab 2](../02.0)
{{% /alert %}}


{{< onlyWhen rancher >}}


## Task {{% param sectionnumber %}}.2: Discover the Rancher web console

Check the menu entries, there should neither appear any deployments nor any Pods or Services in your namespace.

Display all existing Pods in the previously created namespace with `kubectl`  (there should not yet be any!):

```bash
kubectl get pod -n <namespace>
```

With the command `kubectl get` you can display all kinds of resources of different types.
{{< /onlyWhen >}}
