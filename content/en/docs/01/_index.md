---
title: "1. Introduction"
weight: 1
sectionnumber: 1
---

{{% onlyWhenNot openshift %}}
In this lab, we will introduce the core concepts of Kubernetes.

All explanations and resources used in this lab give only a quick and not detailed overview. Please check [the official documentation](https://kubernetes.io/docs/concepts/) to get further details.
{{% /onlyWhenNot %}}

{{% onlyWhen openshift %}}
In this lab, we will introduce the core concepts of OpenShift.

All explanations and resources used in this lab give only a quick and not detailed overview.
As OpenShift is based on Kubernetes, its concepts also apply to OpenShift which you find in [the official Kubernetes documentation](https://kubernetes.io/docs/concepts/).
{{% /onlyWhen %}}


## Core concepts

{{% onlyWhenNot openshift %}}
With the open source software Kubernetes, you get a platform to deploy your application in a container and operate it at the same time.
Therefore, Kubernetes is also called a _Container Platform_, or the term _Container-as-a-Service_ (CaaS) is used.
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
With the open source software OpenShift, you get a platform to build and deploy your application in a container as well as operate it at the same time.
Therefore, OpenShift is also called a _Container Platform_, or the term _Container-as-a-Service_ (CaaS) is used.
{{% /onlyWhen %}}
Depending on the configuration the term _Platform-as-a-Service_ (PaaS) works as well.


### Container engine

{{% onlyWhenNot openshift %}}
Kubernetes' underlying container engine most often is [Docker](https://www.docker.com/). There are other container engines that could be used with Kubernetes such as [CRI-O](https://cri-o.io/).
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
OpenShift's underlying container engine is [CRI-O](https://cri-o.io/). Earlier releases used [Docker](https://www.docker.com/).
{{% /onlyWhen %}}
Docker was originally created to help developers test their applications in their continuous integration environments. Nowadays, system admins also use it.
CRI-O doesn't exist as long as Docker does. It is a "lightweight container runtime for Kubernetes" and is fully [OCI-compliant](https://github.com/opencontainers/runtime-spec).


## Overview

{{% onlyWhenNot openshift %}}
Kubernetes consists of master and worker (minion, compute) nodes.
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
OpenShift basically consists of master and worker nodes.
{{% /onlyWhen %}}


### Master and worker nodes

The master components are the _API server_, the _scheduler_ and the _controller manager_.
The API server itself represents the management interface.
The scheduler and the controller manager decide how applications should be deployed on the cluster. Additionally, the state and configuration of the cluster itself are controlled in the master components.

Worker nodes are also known as compute nodes, application nodes or minions, and are responsible for running the container workload (applications).
The _control plane_ for the worker nodes is implemented in the master components.


### Containers and images

{{% onlyWhenNot openshift %}}
The smallest entities in Kubernetes are Pods, which resemble your containerized application.
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
The smallest entities in Kubernetes and OpenShift are Pods, which resemble your containerized application.
{{% /onlyWhen %}}
Using container virtualization, processes on a Linux system can be isolated up to a level where only the predefined resources are available.
Several containers can run on the same system without "seeing" each other (files, process IDs, network).
One container should contain one application (web server, database, cache, etc.).
It should be at least one part of the application, e.g. when running a multi-service middleware.
In a container itself any process can be started that runs natively on your operating system.

Containers are based on images.
An image represents the file tree, which includes the binary, shared libraries and other files which are needed to run your application.

A container image is typically built from a `Containerfile` or `Dockerfile`, which is a text file filled with instructions.
The end result is a hierarchically layered binary construct.
Depending on the backend, the implementation uses overlay or copy-on-write (COW) mechanisms to represent the image.

Layer example for a Tomcat application:

1. Base image (CentOS 7)
1. Install Java
1. Install Tomcat
1. Install App

The pre-built images under version control can be saved in an image registry and can then be used by the container platform.
{{% onlyWhenNot openshift %}}


### Namespaces

{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}


### Namespaces and Projects

{{% /onlyWhen %}}
Namespaces in Kubernetes represent a logical segregation of unique names for entities (Pods, Services, Deployments, ConfigMaps, etc.).
{{% onlyWhen openshift %}}
In OpenShift, users do not directly create Namespaces, they create Projects. A Project is a Namespace with additional annotations.

{{% alert title="Note" color="primary" %}}
OpenShift's concept of a Project does not coincide with Rancher's.
{{% /alert %}}
{{% /onlyWhen %}}

{{% onlyWhenNot openshift %}}
Permissions and roles can be bound on a per-namespace basis. This way, a user can control his own resources inside a namespace.
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Permissions and roles can be bound on a per-project basis. This way, a user can control his own resources inside a Project.
{{% /onlyWhen %}}

{{% alert title="Note" color="primary" %}}
Some resources are valid cluster-wise and cannot be set and controlled on a namespace basis.
{{% /alert %}}


### Pods

{{% onlyWhenNot openshift %}}
A Pod is the smallest entity in Kubernetes.
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
A Pod is the smallest entity in Kubernetes and OpenShift.
{{% /onlyWhen %}}
It represents one instance of your running application process.
The Pod consists of at least two containers, one for your application itself and another one as part of the Kubernetes design, to keep the network namespace.
The so-called infrastructure container (or pause container) is therefore automatically added by Kubernetes.

The application ports from inside the Pod are exposed via Services.


### Services

A service represents a static endpoint for your application in the Pod. As a Pod and its IP address typically are considered dynamic, the IP address of the Service does not change when changing the application inside the Pod. If you scale up your Pods, you have an automatic internal load balancing towards all Pod IP addresses.

There are different kinds of Services:

* `ClusterIP`: Default virtual IP address range
* `NodePort`: Same as `ClusterIP` plus open ports on the nodes
* `LoadBalancer`: An external load balancer is created, only works in cloud environments, e.g. AWS ELB
* `ExternalName`: A DNS entry is created, also only works in cloud environments

A Service is unique inside a Namespace.


### Deployment

{{% onlyWhenNot openshift %}}
Have a look at the [official documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Have a look at the [official documentation](https://docs.openshift.com/container-platform/latest/applications/deployments/what-deployments-are.html).
{{% /onlyWhen %}}


### Volume

{{% onlyWhenNot openshift %}}
Have a look at the [official documentation](https://kubernetes.io/docs/concepts/storage/volumes/).
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Have a look at the [official documentation](https://docs.openshift.com/container-platform/latest/nodes/containers/nodes-containers-volumes.html).
{{% /onlyWhen %}}


### Job

{{% onlyWhenNot openshift %}}
Have a look at the [official documentation](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/).
{{% /onlyWhenNot %}}
{{% onlyWhen openshift %}}
Have a look at the [official documentation](https://docs.openshift.com/container-platform/latest/nodes/jobs/nodes-nodes-jobs.html).
{{% /onlyWhen %}}
