---
title: "1.0 - Quicktour Kubernetes"
weight: 10
---

# Lab 1: Quicktour Kubernetes

In this lab we will introduce the core concepts of Kubernetes.

All explanations and resources used in this labs give only a quick and not detailed overview. Please check [the official documentation](https://kubernetes.io/docs/concepts/) to get further details.


## Core concepts

Using the open source software Kubernetes, you get a platform to deploy your software in a container and operate them at the same time. Therefore Kubernetes is also called "Container Platform" or the term Container-as-a-Service (CaaS) is used. Depending on the configuration Platform-as-a-Service (PaaS) works as well.


### Docker

[Docker](https://www.docker.com/) known as _the_ container engine can be used with Kubernetes besides other container engines (CRI-O). Originally docker was created to help developers testing there applications in there continuous integration environments. Nowadays also also system admins use it. After choosing the best matching base image for your technology kubernetes deploys for you the application as a container.


## Overview

Kubernetes consists out of Kubernetes master nodes and kubernetes minion (also knows as worker or compute) nodes.

### Master and minion nodes
The master components are the _apiserver_, the _scheduler_ and the _controller-manager_.
The _apiserver_ itself represents the management interface.
The scheduler and the controller-manager decide, which applications should be deployed on the cluster. Additionally the state and configuration of the cluster itself is controlled in the master components
Minion nodes are also known as compute nodes, which are responsible for running the workloads (applications).
The Control plane for the minions is implemented in the master components.



### Container and images

The smallest entities in Kubernetes are pods, which resamble your "containerized Application".
Using container virtualisation, processes on a linux system can be isolated up to a level, where only the predefined resources are available. Several containers can run on the same system, without "seeing" eachother (files, process ids, network). One container should contain one application (webserver, database, cache etc.).
It should be at least one part of the application, e.g. when running a multi service middleware.
In a container itself any process can be started, that runs native on your oparating system.

Containers are based on images. An image represents the file tree, which includes the binary, shared libraries and other files, which are needed to run your application.

A Container image typically is built from a Dockerfile, which is a text file filled with instructions. The endresult is a hierachically, layered binary construct.
Depending on the used backend, most of the time the implementation is using overlay or COW mechanismens to represent the image.

**Layer example Tomcat**
- Base image (CentOS 7)
- + install Java
- + install Tomcat
- + install App

The ready built images can be version-controlled saved in an image registry and can be used by the container platform.


### Namespaces

Namespaces in Kubernetes represent a logical segregation of unique names for entities (pods, services, deployments, configmaps, etc.)

Permissions and roles can be bound on a namespace base. This way a user can control his own resources inside a namespace.
**Note:** Some resources are clusterwide valid and can not be set and controlled on a namespace based.


### Pods

A Pod is the smallest entity in Kubernetes. It represents one instance of your running application process.
The pod consists out of at least two containers, one for your application itself and another one as part of the kubernetes design, to keep the network namespace.
The so called infrastructure container (or pause container) therefore is automatically added by Kubernetes.

The applications port from inside the pod are exposed via services.


### Services

A service represents a stateful endpoint for your application in the pod. As a pod and its IP address typically is considered as stateless, the IP address of the service does not change, when changing the application inside the Pod. If you scale up your pods, you have an automatic internal load balancing towards all pod ip addresses.

There are different kinds of services:
- ClusterIP (the default, virtual IP address range)
- NodePort (same as ClusterIP + open ports on the nodes)
- LoadBalancer (external loadbalancer is created, works only in cloud environment, e.g. AWS elb)

A service is unique inside a namespace.
 
### Deployment

Please follow <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>


### Volume

Please follow <https://kubernetes.io/docs/concepts/storage/volumes/>


### Job

Please follow <https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/>

---

**End of lab 1**