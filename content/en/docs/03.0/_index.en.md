---
title: "3. First steps in the lab environment"
weight: 3
---


In this excercise we will interact for the first time with the lab environment, both with `kubectl` as well as via web console.

{{% alert title="Tip" color="warning" %}}
Please make sure, the be finshed with [Lab 2](../02.0/) before continue with this lab.
{{% /alert %}}


### Login and choose Kubernetes Cluster

{{< onlyWhen rancher >}}
Our Kubernetes cluster of the techlab environment runs on [cloudscale.ch](https://cloudscale.ch) (a swiss IaaS Provider) and has been provisioned with [Rancher](https://rancher.com/). You can login into the cluster with a Rancher user.

{{% alert title="Tip" color="warning" %}}
For details about your credentials to log in, ask your teacher.
{{% /alert %}}
{{< /onlyWhen >}}

{{< onlyWhen rancher >}}
Login into the Rancher WebGUI choose the desired cluster.

On the cluster dashboard you find top right a button with `Kubeconfig File`. Save the config file into your homedirectory `.kube/config`. Verify afterwards if `kubectl` works correctly e.g. with `kubectl version`

![Download Kubeconfig File](kubectlconfigfilebutton.png)

{{% alert title="Tip" color="warning" %}}
If you already have a kubeconfig file, you might need to merge the Rancher entries with yours. Or use the KUBECONFIG environment variable to specify a dedicated file.
{{% /alert %}}

```
#example location ~/.kube-techlab/config
vim ~/.kube-techlab/config
# paste content

# set KUBECONFIG Environment Variable to the correct file
export KUBECONFIG=$KUBECONFIG:~/.kube-techlab/config
```
{{< /onlyWhen >}}


## Namespaces

As a first step we are going to create a new namespace.

A namespace is the logical design used in Kubernetes to organize and separate your applications, deployments, pods, ingress, services etc. on a top level base. Take a look at the [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). Authorized users inside that namespace are able to manage those resources. Namespace names have to be unique in your cluster.

{{< onlyWhen rancher >}}
{{% alert title="Note" color="warning" %}}
Additionaly Rancher does know the concept of a [project](https://rancher.com/docs/rancher/v2.x/en/cluster-admin/projects-and-namespaces/) which encapsulates multiple namespaces.
{{% /alert %}}

In the Rancher WebGUI you can now choose your Project called `techlab`

![Rancher Project](chooseproject.png)

{{< /onlyWhen >}}


### Exercise: Create a Namespace

Create a new namespace in the lab environment.

{{% alert title="Note" color="warning" %}}
Please choose an identifying name for the namespace, in best case your abbreviation. We are going to use <NAMESPACE> as a placeholder for your created namespace.
{{% /alert %}}

> How can a new namespace be created?

**Tip** `kubectl` can help you to figure out the right commands:

```bash
kubectl help
```


### Solution

To create a new namespace on your cluster use the following command:

```bash
kubectl create namespace <NAMESPACE>
```

{{< onlyWhen rancher >}}
{{% alert title="Note" color="warning" %}}
Namespaces created via `kubectl`, have to be assigned to your Rancher project in order to be seen inside the Rancher WebGUI. Ask your teacher for the assignement. Or you can create the namespace directlly within the Rancher WebGui
{{% /alert %}}
{{< /onlyWhen >}}

**Tip:** By using the following command, you can switch into another namespace instead of specifly the namespace in each `kubectl` command:
```bash
# Linux:
kubectl config set-context $(kubectl config current-context) --namespace=<NAMESPACE>
```

```
# Windows:
kubectl config current-context
// Save the context in a variable
SET KUBE_CONTEXT=[Insert output of the upper command]
kubectl config set-context %KUBE_CONTEXT% --namespace=<NAMESPACE>
```

{{% alert title="Tip" color="warning" %}}
Some prefer to explicitly select the namespace for each `kubectl` command by adding `--namespace <NAMESPACE>`
or `-n <NAMESPACE>`. And others prefer helper tools like `kubens` (see lab 2)
{{% /alert %}}


## Exercise: discover the web console

Check the menu entries, there should neither appear any deployments nor any pods or services in your namespace.

Display all existing pods in the previously created namespace with `kubectl`  (there should not yet be any!):

```bash
kubectl get pod -n=<NAMESPACE>
```

With the command `kubectl get` you can display all kinds of resources of different types.