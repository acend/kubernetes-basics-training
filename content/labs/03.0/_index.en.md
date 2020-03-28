---
title: "3.0 - First steps in the lab environment"
weight: 30
---

# Lab 3: First steps in the lab environment

In this excercise we will interact for the first time with the lab environment, both with `kubectl` as well as via web console.


## Preparation for the labs

Please clone the git repository, to have a local copy of all necessary excercises.

```
$ cd [Git Repo Project Folder]
$ git clone https://github.com/puzzle/kubernetes-techlab.git
```

As a fallback the repository can be downloaded as [zip file](https://github.com/puzzle/kubernetes-techlab/archive/master.zip).


## Login

**Note:** Please make sure, the be finshed with [Lab 2](02_cli.md).

Our Kubernetes cluster of the techlab environment runs on [cloudscale.ch](https://cloudscale.ch) and has been provisioned with [Rancher](https://rancher.com/). You can login into the cluster with a Rancher user.

**Note:** For details about your credentials to log in, ask your teacher.



### Login and choose Kubernetes Cluster

Login into the Rancher WebGUI with your assigned user and the choose the desired cluster.


On the cluster dashboard you find top right a button with `Kubeconfig File`. Save the config file into your homedirectory `.kube/config`. Verify afterwards if `kubectl` works correctly e.g. with `kubectl version`

**Note:** If you already have a kubeconfig file, you might need to merge the Rancher entries with yours. Or use the KUBECONFIG environment variable to specify a dedicated file.

```
#example location ~/.kube-techlab/config
vim ~/.kube-techlab/config
# paste content 

# set KUBECONFIG Environment Variable to the correct file
export KUBECONFIG=$KUBECONFIG:~/.kube-techlab/config
```


## Create a namespace

A namespace is the logical design used in Kubernetes to organize and separate your applications, deployments, services etc. on a top level base. Take a look at the [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/).


**Note:** Additionaly Rancher does know the concept of a [project](https://rancher.com/docs/rancher/v2.x/en/cluster-admin/projects-and-namespaces/) which encapsulates multiple namespaces.

In the Rancher WebGUI you can now choose your Project.



## Exercise: LAB3.1

Create a new namespace in the lab environment.

**Note**: Please choose an identifying name for the namespace, in best case your the techlab username, e.g. `[TEAM]-lab3-1`

> How can a new namespace be created?

**Tip** :information_source:
```
$ kubectl help
```

**Tip:** By using the following command, you can switch into another namespace:
```
Linux:
$ kubectl config set-context $(kubectl config current-context) --namespace=[TEAM]-lab3-1
```

```
Windows:
$ kubectl config current-context
// Save the context in a variable
SET KUBE_CONTEXT=[Insert output of the upper command]
$ kubectl config set-context %KUBE_CONTEXT% --namespace=[TEAM]-lab3-1
```


**Note:** Namespaces created via `kubectl`, have to be assigned to your project in order to be seen inside the Rancher WebGUI. Ask your teacher for the assignement.

## Exercise: LAB3.2 discover the web console


Please check the menu entries, there should neither appear any deployments nor any pods or services.


---

## Solution: LAB3.1

```
$ kubectl create namespace [TEAM]-lab3-1
```
---

It is bestpractice to explicitly select the Namespace in each `kubectl` command by adding `--namespace namespace` or in short`-n namespace`.

---

**Ende Lab 3**
