---
title: "10.2  DaemonSet"
weight: 102
sectionnumber: 10.2
---

A DaemonSet is almost identical to a normal deployment. It makes sure that exactly one Pod is running on every (or some specified) Node. When a new Node is added, the DaemonSet automatically deploys a Pod on the new Node.
When the DaemonSet is deleted, all related Pods are deleted.

One excellent case to use case for a DaemonSet is a daemon to grab logs from Nodes (e.g., Fluentd, Logstash or a Splunk forwarder)

More information about DaemonSet can be found in the [Kubernetes DaemonSet Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/).
