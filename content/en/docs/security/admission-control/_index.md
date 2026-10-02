---
title: "Admission Control"
weight: 104
onlyWhen: openshift
---

## Admission Control

Not every restriction you wish to impose on cluster usage can be expressed as an
RBAC rule. Frequently, organisations want to enable users to perform certain tasks
while limiting their options to a subset of what the platform itself allows. For
example, users should be able to create `Service` resources, but `Services` of
`type: LoadBalancer` (which the cloud provider charges extra for) should be
restricted to specific privileged namespaces. Or a multi-tenant cluster might
enforce `imagePullPolicy: Always` in user namespaces to ensure pull credential
verification with private images (at least until a [better
solution](https://kubernetes.io/docs/concepts/containers/images/#ensureimagepullcredentialverification)
becomes generally available).

There is a wide range of these typically site-specific _policy decisions_, that
require additional capabilities to validate or even modify API requests beyond
the base capabilities of the Kubernetes control plane. To address these needs,
the API server offers a flexible subsystem for _admission control_. It
ships with numerous pre-defined admission controllers (such as `PodSecurity` or
`ResourceQuota`) that can be enabled or disabled according to individual needs.
In OpenShift, this list is managed by the platform and cannot be manually reconfigured.
However, admission control can still be extended effectively because the
default controllers include a generic, webhook-based interface where additional
plugins can be injected.

Traditionally, dedicated policy engines such as [Open Policy
Agent/Gatekeeper](https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/)
or [Kyverno](https://kyverno.io/) have utilised this mechanism to provide a
flexible option for admins to configure and enforce site-specific regulations.
In recent versions of Kubernetes, this process has become even more straightforward.
Starting with version 1.30 (or OpenShift 4.17),
[`ValidatingAdmissionPolicy`](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/)
was added to the stable set of native Kubernetes resources. It allows
incoming requests to be checked against a list of rules in Common Expression Language
(CEL) format, allowing or denying the request based on the outcome.

Its companion,
[`MutatingAdmissionPolicy`](https://kubernetes.io/docs/reference/access-authn-authz/mutating-admission-policy/)
remains in beta as of Kubernetes 1.34, and is therefore not yet available in OpenShift
by default. Unlike its validating counterpart, it can modify parts of a
request on the fly. Until this feature graduates to `stable`, administrators
must resort to external policy engines if they wish to adjust
incoming manifests to comply with site restrictions, rather than simply rejecting
them.

### {{% task %}} Explore Admission Control

The lab environment already includes a few sample policies that you can explore
to familiarise yourself with [CEL](https://cel.dev/),
[`ValidatingAdmissionPolicy`
objects](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/)
and their related `ValidatingAdmissionPolicyBindings`. You will not have
privileges required to add or modify these resources, but you can ask your
tutors to check and apply them for you -- once they are confident it will not
impair cluster operations... You may also wish to take a look at the
[Kubescape](https://kubescape.io/) project, which provides a curated list of
policy examples.
