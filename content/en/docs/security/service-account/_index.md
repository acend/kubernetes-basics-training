---
title: "Service Accounts"
weight: 103
onlyWhenNot: openshift
---

A Kubernetes Service Account is an identity used by pods to interact with the Kubernetes API securely. It provides authentication for workloads running inside a cluster, enabling them to access resources such as secrets, config maps, or other API objects. By default, every pod is assigned a service account, but custom service accounts with specific permissions can be created using Role-Based Access Control (RBAC) to enforce security and least privilege principles.


## {{% task %}} Create a Service Account

Create a file named `sa.yaml` and define the ServiceAccount:

{{< readfile file="/content/en/docs/security/service-account/sa.yaml" code="true" lang="yaml" >}}

and apply this file using:

```bash
{{% param cliToolName %}} apply -f sa.yaml --namespace <namespace>
```


## {{% task %}} Create a Role and a Rolebinding

In Kubernetes, Role-Based Access Control (RBAC) is used to manage permissions for users, applications, and system components.

* A Role defines a set of permissions (such as reading or modifying resources) within a specific namespace. It grants access to resources like pods, services, or config maps.
* A RoleBinding links a Role to a ServiceAccount, a user, or a group, effectively assigning the permissions defined in the Role to that entity.

In this task, we will create a Role that allows listing pods and bind it to our ServiceAccount so that it has the necessary permissions to query running pods.

Create a file named `role.yaml` to define a Role with permissions to list Pods:

{{< readfile file="/content/en/docs/security/service-account/role.yaml" code="true" lang="yaml" >}}

Now create a `rolebinding.yaml` file to bind the Role to the ServiceAccount (make sure that the namespace in `subject` is correctly set to your namespace):

{{< readfile file="/content/en/docs/security/service-account/rolebinding.yaml" code="true" lang="yaml" >}}

and apply both files using:

```bash
{{% param cliToolName %}} apply -f role.yaml --namespace <namespace>
{{% param cliToolName %}} apply -f rolebinding.yaml --namespace <namespace>
```


## {{% task %}} Create a Job That Lists Running Pods

And now finaly we start a Kubernetes Job thas lists all running pods. Create the `job.yaml` file with the following content:

{{< readfile file="/content/en/docs/security/service-account/job.yaml" code="true" lang="yaml" >}}

```bash
{{% param cliToolName %}} apply -f job.yaml --namespace <namespace>
```

Once the job runs, check the logs to see the list of running pods:

```bash
{{% param cliToolName %}} logs -l job-name=list-pods-job --namespace <namespace>
```

The job should list all running pods in your namespace.


## Why is kubectl in the Job Using the Created Service Account?

In Kubernetes, when a Pod runs, it automatically assumes the identity of a ServiceAccount assigned to it. By default, Pods use the default ServiceAccount, which has minimal permissions. However, we explicitly assigned our `pod-reader` ServiceAccount to the Job using:

```yaml
serviceAccountName: pod-reader
```

How This Works:

1. When a pod is created, Kubernetes automatically mounts a ServiceAccount token inside the pod at `/var/run/secrets/kubernetes.io/serviceaccount/token.` This token is a JWT (JSON Web Token) used for authenticating with the Kubernetes API.
2. The RoleBinding connects the `pod-reader` ServiceAccount to the Role that allows listing pods.
   When kubectl get pods runs inside the Job’s container, it authenticates using the pod-reader ServiceAccount token.
3. The `kubectl` command inside the Pod is executed with the permissions granted by the Role.
   Since we only gave "get" and "list" permissions on Pods, the job can list Pods but not modify or delete them.
   This ensures least privilege access, improving security by preventing unnecessary permissions from being granted.

When `kubectl` runs inside a Pod, it follows Kubernetes in-cluster authentication process. Specifically, it:

* Checks for the `KUBERNETES_SERVICE_HOST` and `KUBERNETES_SERVICE_PORT` environment variables, which are automatically set inside every Pod to point to the Kubernetes API server.
* Looks for credentials in `~/.kube/config` (like when used locally).
* If no kubeconfig is found, it falls back to in-cluster authentication, which means it:
  * Reads the token from `/var/run/secrets/kubernetes.io/serviceaccount/token`
  * Uses the CA certificate at `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` to verify the API server
  * Identifies itself as the ServiceAccount assigned to the Pod
