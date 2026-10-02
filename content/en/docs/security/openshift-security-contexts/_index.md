---
title: "Security contexts constraints"
weight: 102
onlyWhen: openshift
---

## Security Context and Context Constraints

The [Security Context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
of a `Pod` or container informs the container runtime about the
privileges, capabilities, and desired level of isolation for a
containerised workload:

* Access control
* Running privileged or unprivileged workloads
* Linux capabilities
* Seccomp
* SELinux

OpenShift offers a custom resource, the
[SecurityContextConstraint](https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/authentication_and_authorization/managing-pod-security-policies)
(SCC), to manage sensible defaults and control what users are allowed to configure.
In this lab, you will learn some simple but common use cases for adjusting
the security context and how to make use of SCCs.

### {{% task %}} Container UID and GIDs

Provision a new project and add a workload from one of the OpenShift-provided
samples. You can use the Quick Create button (the plus sign) in the upper right
corner, select 'Container images', and create a `Deployment` from an 'Image
stream tag from internal registry'. One of the Apache webservers located in the
'openshift' project, Image Stream 'httpd' is a good choice. Any tag will do.
Provide an arbitrary name and leave the remaining settings at their defaults.
Creating a route is not necessary. The deployment will spawn a single httpd `Pod`.

Open a terminal in this `Pod` and run the 'id' command to investigate the numeric
User ID (UID) and Group IDs (GIDs) assigned to the container. Note that a seemingly
random UID from a high range was chosen. This is one of the idiosyncrasies of OpenShift
compared to other Kubernetes platforms, and a common source of problems for
certain workloads that expect to run with a well-known UID, such as '1000'.

Switch to the YAML view for the `Deployment` (or use 'oc edit'), and attempt to
run the httpd container with UID 1000, and GIDs 1000, 2000, and 3000. This is
achieved by modifying the `Pod`'s security context:

{{% alert title="Note" color="primary" %}}
There are `securityContext` parameters at both the `Pod` and the container level.
Some options may be set in either of thoses
contexts, while others are specific to one, or the other.
{{% /alert %}}

```yaml
spec:
  template:
    spec:
      # (...)
      # Pod-level security context!
      # runAs* can also be set at container level
      # supplementalGroups is only valid at Pod level
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        supplementalGroups: [2000, 3000]
```

While the deployment accepts the modification, it will fail to roll out an updated `Pod`
with the new settings. Its status will show a long list of 'Forbidden' error messages
similar to the following:

```
pods "httpd-6d788c7686-" is forbidden: unable to validate against any security context constraint: [provider "anyuid": Forbidden: not usable by user or serviceaccount, provider restricted-v2: .containers[0].runAsUser: Invalid value: 1000: must be in the ranges: [1000940000, 1000949999], provider "restricted-v3": Forbidden: not usable by user or serviceaccount, provider "restricted": Forbidden: not usable by user or serviceaccount, provider "nonroot-v2": Forbidden: not usable by user or serviceaccount,(...)
```

Note the section `Invalid value: 1000: must be in the ranges: [1000940000,
1000949999]` (the specific range you see will be different). Inspect the annotations on
your 'Project' for this lab task, where you will find two keys:
`openshift.io/sa.scc.uid-range`, and `openshift.io/sa.scc.supplemental-groups`.
These values were auto-generated when the project was
created and contain an assigned range for User and Group IDs that does not
overlap with other projects in the same cluster.
They can only be changed with elevated privileges beyond those of a regular project admin.

Back in the YAML view for the `Deployment`, change the UID in the `runAsUser`
parameter from 1000 to the last uid from the assigned range (here: 1000949999),
but leave the `runAsGroup` and `supplementalGroups` parameters at their current
values. The deployment should now be able to spawn a new `Pod` with the updated
configuration. Switch to the terminal view for the `Pod`, and run 'id' to verify
the assignments.

Finally, add the `fsGroup` parameter to the pod's (not the container's!) security context.
Try to set different, arbitrary IDs. There is only one specific value that is accepted during
pod re-creation, and that is the GID that would also be assigned by default
(here: 1000940000). The `fsGroup` parameter is used to change ownership when
attaching volumes to a `Pod`, and its (default or explicit) value is always added
as a supplemental GID.

These are just some of the most basic settings controlled by a security context.
Check the documentation at kubernetes.io to view all the examples for
[Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/).

### {{% task %}} Security Context Constraints

Having explored what security contexts can do, you will now investigate
how OpenShift controls them. Run the following command to determine your
privileges regarding the OpenShift-specific 'SecurityContextConstraint' resource:

```bash
oc auth can-i --list | grep securitycontextconstraints.security.openshift.io
securitycontextconstraints.security.openshift.io                              []                                          [restricted-v2]                                                    [use]
```

The output shows that you are permitted to 'use' exactly one SCC called
'restricted-v2', but you are not permitted to view its content ('get').
To proceed, ask your tutors to assign additional privileges to your user, or
follow along as they demonstrate the next sections.

By default, OpenShift clusters ship with a ClusterRole for 'use'
privileges on the 'restricted-v2' SCC. This is typically assigned 
to the 'system:authenticated' group (that is all users and
service accounts with a valid login session). However, there are several other
SCCs available in the clusters, three of which are most commonly encountered in
user projects:

```bash
oc get scc restricted-v2,restricted-v3,nonroot-v2 -o wide
NAME            PRIV    CAPS                   SELINUX     RUNASUSER          FSGROUP     SUPGROUP    PRIORITY     READONLYROOTFS   VOLUMES
restricted-v2   false   ["NET_BIND_SERVICE"]   MustRunAs   MustRunAsRange     MustRunAs   RunAsAny    <no value>   false            ["configMap","csi","downwardAPI","emptyDir","ephemeral","persistentVolumeClaim","projected","secret"]
restricted-v3   false   ["NET_BIND_SERVICE"]   MustRunAs   MustRunAsRange     MustRunAs   MustRunAs   <no value>   false            ["configMap","csi","downwardAPI","emptyDir","ephemeral","persistentVolumeClaim","projected","secret"]
nonroot-v2      false   ["NET_BIND_SERVICE"]   MustRunAs   MustRunAsNonRoot   RunAsAny    RunAsAny    <no value>   false            ["configMap","csi","downwardAPI","emptyDir","ephemeral","persistentVolumeClaim","projected","secret"]
```

Note how 'restricted-v2' restricts the user to the UID range configured in the project
annotation (`MustRunAsRange`), and the fsGroup to the project's default value
(`MustRunAs`). Crucially, it imposes no limits on supplemental groups (`RunAsAny`), even
if a range is configured in the project's annotation. This explains why
only the `runAsUser` modifications were blocked in your earlier tests, while
groups could be set to arbitrary values (including GID 0!).

In contrast, the more recent 'restricted-v3' SCC honours the project annotation
to enforce limits on the allowed GID range. It also includes security enhancements
not visible in the brief `-o wide` overview, and is not yet assigned to any subjects
by default.

The 'nonroot-v2' SCC is a common choice when workloads cannot be easily
adjusted to accommodate OpenShift's randomly assigned UIDs. It is similar to
'restricted-v2', but allows 'runAsUser' to be configured to any arbitrary value
except for UID 0. Unless already done, ask your tutors to assign this privilege
to your user. (The privilege is needed by a service account in the end, but you
can only grant privileges that you hold.) Next, to replicate a realistic production
setup, follow these steps:

1. Create a new service account in your project.
2. Update your `httpd` `Deployment` to use this 'serviceAccountName'.
3. Assign 'use' privileges for the 'nonroot-v2' SCC to this service account.
   You can reference the default 'system:openshift:scc:nonroot-v2' ClusterRole.
4. Re-run the previous tests and verify that the `Pods` can now start with arbitrary
   non-root UIDs.

{{% alert title="Warning" color="warning" %}}
Do not confuse 'nonroot-v2' with the 'anyuid' SCC. The latter permits UID 0, which
poses a significant security risk and should be avoided whenever possible.
{{% /alert %}}

