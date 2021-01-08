---
title: "13. Kubernetes and OpenShift differences"
weight: 13
sectionnumber: 13
onlyWhen: openshift
---

Even though OpenShift is based on Kubernetes, there are some important differences.
As a concluding lab we are going to have a look at these differences.


## Life cycle and versions

Red Hat releases a new OpenShift 4 release every six months, as is the case with Kubernetes.
The important difference however is that the latest OpenShift release is always based upon the second latest Kubernetes release.

Keep this in mind especially when using Kubernetes' documentation e.g. about some resource type.

You can find out more about OpenShift's life cycle policy on [this page](https://access.redhat.com/support/policy/updates/openshift/).


## Resource types

OpenShift extends the Kubernetes API to support certain additional resource types.


### Namespaces and Projects

In [lab 2](../02/) you created your first Project on OpenShift.
You won't find the concept of a "Project" in Kubernetes except in other Kubernetes distributions, specifically in Rancher.

{{% alert title="Note" color="primary" %}}
[Rancher's](https://rancher.com/docs/rancher/v2.x/en/cluster-admin/projects-and-namespaces/#about-projects) and [OpenShift's](https://docs.openshift.com/container-platform/latest/rest_api/project_apis/project-apis-index.html) concepts of a project have nothing in common.
{{% /alert %}}

A Project in OpenShift is based on the Namespace resource type.
In fact, when creating a Project in OpenShift, a Namespace with the exact same name is created in the background.

The probably only reason for the Project resource type to exist is that OpenShift provides additional administrative controls for Projects.
OpenShift users can e.g. [be prevented from creating their own Namespaces/Projects](https://docs.openshift.com/container-platform/latest/applications/projects/configuring-project-creation.html#disabling-project-self-provisioning_configuring-project-creation).


### Ingresses and Routes

Ingresses and Routes enable you to make an application reachable to the outside of OpenShift.
They contain the configuration needed and signal the platform that a certain service needs to be accessible to the outside world.

Red Hat introduced the concept of Routes in OpenShift 3.0 and still uses it up until now.
Support for the Ingress resource type was [introduced in OpenShift 3.10](https://docs.openshift.com/container-platform/3.10/release_notes/ocp_3_10_release_notes.html#ocp-310-support-for-kubernetes-ingress-objects) which means that you can use both Routes and Ingresses as you see fit. Of course both have their advantages and disadvantages.

One of the obvious advantages of the Ingress resource type is its compatibility with other Kubernetes distributions.
However, different kinds of Ingress controllers support different features making this statement semisolid.
One of the obvious advantages of using Routes is that they're easy to create using the `oc expose` command.

{{% alert title="Note" color="primary" %}}
In OpenShift, creating an Ingress resource leads to the creation of a corresponding Route in the same Namespace.
{{% /alert %}}


#### Task {{% param sectionnumber %}}.1: Create an Ingress resource

In [lab 5](../05/) you exposed the example-web-python application via Route using the `oc expose` command.

Expose the application using an Ingress resource.
It's best to not delete the existing Route so you can compare them.
Bear in mind that you need to use another hostname in that case.

{{% alert title="Note" color="primary" %}}
Make use of the Kubernetes documentation about Ingress resources.
{{% /alert %}}


#### Solution {{% param sectionnumber %}}.1: Create an Ingress resource

Your Ingress resource should look similar to this:

{{< highlight yaml >}}{{< readfile file="content/en/docs/13_openshift/ingress_v1beta1.yaml" >}}{{< /highlight >}}


### Deployments and DeploymentConfigs

OpenShift introduced the concept of _DeploymentConfigs_ which got later introduced to upstream Kubernetes as Deployments.
The reason they don't have the same name is because Deployments lack some of the features DeploymentConfigs offer.
It's advisable however to use Deployments wherever possible as they're compatible with other Kubernetes distributions where DeploymentConfigs are only supported on OpenShift.

The [OpenShift documentation](https://docs.openshift.com/container-platform/latest/applications/deployments/what-deployments-are.html) offers a detailed explanation of the differences.
The features additionally offered by DeploymentConfigs can be summarized as automation features to e.g. automatically trigger a new deployment when the upstream image is updated.


### ImageStreams

One of the reasons Kubernetes Deployments cannot support the missing automation features is because in OpenShift, they are based on other resource types like the _ImageStream_.
Kubernetes has not yet adopted a similar resource type.

ImageStreams are references to an actual image in an image registry.
They can be configured to periodically check if the referenced image has been updated in order to trigger builds or deployments.
More details can be found in [OpenShift's documentation](https://docs.openshift.com/container-platform/latest/openshift_images/images-understand.html#images-imagestream-use_images-understand).


### BuildConfigs and Builds

You already encountered these resource types in [lab 3](../03/). BuildConfigs and Builds make it possible to build a container image on OpenShift instead of relying on an external tool.
