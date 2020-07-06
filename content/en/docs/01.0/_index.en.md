---
title: "1. Quick tour of Kubernetes"
weight: 1
sectionnumber: 1
---

In this lab, we will introduce the core concepts of Kubernetes.

All explanations and resources used in this lab give only a quick and not detailed overview. Please check [the official documentation](https://kubernetes.io/docs/concepts/) to get further details.


## Core concepts

With the open source software Kubernetes, you get a platform to deploy your application in a container and operate it at the same time. Therefore, Kubernetes is also called a _Container Platform_ or the term _Container-as-a-Service_ (CaaS) is used. Depending on the configuration the term _Platform-as-a-Service_ (PaaS) works as well.


### Docker

[Docker](https://www.docker.com/) known as _the_ container engine can be used with Kubernetes besides other container engines (CRI-O). Originally, Docker was created to help developers test their applications in their continuous integration environments. Nowadays also system admins use it. After choosing the best matching base image for your technology Kubernetes deploys for you the application as a container.


## Overview

Kubernetes consists of master and worker (minion, compute) nodes.


### Master and worker nodes

The master components are the _API server_, the _scheduler_ and the _controller manager_.
The API server itself represents the management interface.
The scheduler and the controller manager decide how applications should be deployed on the cluster. Additionally, the state and configuration of the cluster itself is controlled in the master components.

Worker nodes are also known as compute nodes or minions and are responsible for running the container workload (applications).
The _control plane_ for the worker nodes is implemented in the master components.


### Containers and images

The smallest entities in Kubernetes are Pods, which resemble your containerized application.
Using container virtualization, processes on a Linux system can be isolated up to a level where only the predefined resources are available. Several containers can run on the same system without "seeing" each other (files, process IDs, network). One container should contain one application (web server, database, cache, etc.).
It should be at least one part of the application, e.g. when running a multi-service middleware.
In a container itself any process can be started that runs natively on your operating system.

Containers are based on images. An image represents the file tree, which includes the binary, shared libraries and other files which are needed to run your application.

A container image typically is built from a `Dockerfile`, which is a text file filled with instructions. The end result is a hierarchically layered binary construct.
Depending on the backend the implementation is using overlay or copy-on-write (COW) mechanisms to represent the image.

Layer example for a Tomcat application:

1. Base image (CentOS 7)
1. Install Java
1. Install Tomcat
1. Install App

The pre-built images under version control can be saved in an image registry and can then be used by the container platform.


### Namespaces

Namespaces in Kubernetes represent a logical segregation of unique names for entities (Pods, Services, Deployments, ConfigMaps, etc.)

Permissions and roles can be bound on a per-namespace basis. This way, a user can control his own resources inside a namespace.

{{% alert title="Note" color="primary" %}}
Some resources are valid cluster-wise and cannot be set and controlled on a namespace basis.
{{% /alert %}}


### Pods

A Pod is the smallest entity in Kubernetes. It represents one instance of your running application process.
The Pod consists of at least two containers, one for your application itself and another one as part of the Kubernetes design, to keep the network namespace.
The so called infrastructure container (or pause container) therefore is automatically added by Kubernetes.

The application ports from inside the Pod are exposed via Services.


### Services

A service represents a static endpoint for your application in the Pod. As a Pod and its IP address typically are considered dynamic, the IP address of the Service does not change when changing the application inside the Pod. If you scale up your Pods, you have an automatic internal load balancing towards all Pod IP addresses.

There are different kinds of Services:

* `ClusterIP`: Default virtual IP address range
* `NodePort`: Same as `ClusterIP` plus open ports on the nodes
* `LoadBalancer`: An external load balancer is created, works only in cloud environments, e.g. AWS ELB
* `ExternalName`: A DNS entry is created, also works only in cloud environments

A Service is unique inside a namespace.


### Deployment

Please follow <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>.


### Volume

Please follow <https://kubernetes.io/docs/concepts/storage/volumes/>.


### Job

Please follow <https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/>.
