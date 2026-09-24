---
title: "User and Identity Management"
weight: 103
onlyWhen: openshift
---

## User and Identity Management

So far, you have interacted with the OpenShift cluster using your own account,
leveraging privileges assigned to your user's groups.  This
likely felt natural, as it is exactly what one would expect from any multi-user
system. It may, therefore, come as a surprise that Kubernetes does not actually
include any native user management capabilities. Yet, running `oc whoami` clearly
indicates that the system identifies you as a user. How do we reconcile these
two facts?

Your tutors will now assign additional privileges to your account to enable
you to inspect the `User`, `Group`, and `Identity` resources. Take a
look at the YAML representation of one of these, specifically the
`apiVersion` field: you will notice they are OpenShift-specific extensions.
Other Kubernetes distributions may ship their own abstractions for user management,
or might not include any at all.

In OpenShift, user management revolves around the configuration of its
built-in OAuth service. Your new privileges allow you to examine
its primary configuration in the `OAuth` custom resource called `cluster`. This
resource defines how the cluster integrates with one or more identity providers,
commonly using protocols such as OpenID Connect or LDAP, or even simple
implementations based on a plain 'htpasswd' file.

These identity providers determine how users _authenticate_ to the system.
Upon the first login, an account from one of these providers is reflected by
an `Identity` custom resource. Each `Identity` then maps onto a `User` resource
based on a strategy defined in the `OAuth` configuration. For example, an
`Identity` can correspond to exactly one `User` ('claim it'). If a
person is permitted to log in via multiple identity providers, `Oauth can
be configured to map multiple `Identities` to the same `User`.

When Kubernetes needs to _authorise_ a request, it does not refer to the
`Identity`, but to the `User` (or a `Group`, which is a collection of
`Users`). Recall the `subjects` parameter in a `RoleBinding` or
`ClusterRoleBinding`: it allows you to specify users, groups, or `ServiceAccounts`.
Remarkably, only the `ServiceAccount` is a first-class citizen
in native Kubernetes that is always reflected as an API resource, whereas the other
two lack a standardised internal representation across the wider Kubernetes ecosystem.

If native Kubernetes has no notion of users as API objects, and relies on
distribution-specific add-ons, then how does the system function before they are
even installed? In the next lab, you will create users that aren't there.

### {{% task %}} Creating a Stealth Account

Kubernetes may be agnostic to user management, but it still maintains a notion
of users (and groups). Its most native method for identifying users leverages
X.509 certificates. Once a suitable certificate is signed by a cluster's
trusted Certificate Authority (CA), users can authenticate with it when
communicating with the API server. There is no user database or external management
involved: The Common Name attribute (CN) in the certificate's subject DN is
interpreted as the user name, and any Organization (O) attribute indicates group
membership. This scheme is simple and incurs very little overhead, but it comes at
a price. Once a certificate is signed, Kubernetes does not offer a native way to
track or revoke it (ie. you cannot easily see a list of which users are 'out there').
If a compromise is suspected, the only practical way to invalidate a certificate is
to rotate the CA's keys, which unfortunately invalidates every other certificate
issued by that CA as well!

Let's try this in practice by creating an account with
`cluster-reader` privileges and using certificate-based authentication. Your tutors
have granted you the privilege to create a `CertificateSigningRequest` (CSR). This
is a Kubernetes resource that wraps a PKCS#10 signing request with additional
metadata. Start out by creating a new private key
and the associated signing request:

```bash
export OCPUSER=$(oc whoami)

openssl genrsa -out tls.key 2048
# We define the CN as our username and 'O' as our groups
openssl req -new -key tls.key -out tls.csr -subj "/CN=${OCPUSER}-reader/O=system:cluster-readers/O=stealth-group"

export CSR_BASE64=$(base64 -w0 < tls.csr)

cat <<EOF > "csr-$OCPUSER.yaml"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: csr-${OCPUSER}
spec:
  request: ${CSR_BASE64}
  # required for user certs
  signerName: kubernetes.io/kube-apiserver-client
  # 30 days
  expirationSeconds: 2592000
  usages:
  # required for user certs
  - client auth
EOF
```

Run `oc apply -f csr-$OCPUSER.yaml` to upload the request. Once a tutor has
approved it, retrieve the signed certificate using the following command:

```bash
oc get csr csr-$OCPUSER -o go-template='{{ .status.certificate | base64decode }}' > tls.crt
```

All that remains is to build a valid kubeconfig file. You are already connected
to the cluster and have a valid config at hand (albeit for a different account),
that you could clone and modify. But as a useful excercise, you can run the following
script that pieces together the necessary bits:

```bash
#!/bin/bash

OUTFILE=user.kubeconfig

# ConfigMap containing the CA bundle is injected into every namespace
oc get configmap kube-root-ca.crt -o go-template='{{ index .data "ca.crt" }}' > ca-bundle.crt

# Lazy way to retrieve the API server URL from the current-context
APISERVERURL=$(oc cluster-info | sed -ne 's,.*\(https://.*\),\1,p')

oc config set-cluster default-cluster \
  --server=${APISERVERURL} \
  --certificate-authority=ca-bundle.crt \
  --embed-certs=true \
  --kubeconfig=$OUTFILE

oc config set-credentials default-user \
  --client-certificate=tls.crt \
  --client-key=tls.key \
  --embed-certs=true \
  --kubeconfig=$OUTFILE

oc config set-context default-context \
  --cluster=default-cluster \
  --user=default-user \
  --kubeconfig=$OUTFILE

oc config use-context default-context --kubeconfig=$OUTFILE
```

Now, call `oc --kubeconfig=user.kubeconfig whoami` to test the new configuration.
Using `oc --kubeconfig=user.kubeconfig auth whoami` (note the extra `auth` keyword!),
you can verify your assigned group memberships. Observe the total absence of any associated
`User` or `Group` resources! Despite this, `oc --kubeconfig=user.kubeconfig auth can-i
--list` will show that this 'stealth' account possesses extensive
read-only privileges across the entire cluster. Use this access to further explore the
inner workings of OpenShift!

