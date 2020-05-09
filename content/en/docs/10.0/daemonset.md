---
title: "10.2  DaemonSet"
weight: 102
---

A DaemonSet is almost identical to a normal deployment, but makes sure that on every (or some specified) Node extractly one pod is running. When a new node is added, the daemonset automatically deploys a pod on the new node.
When the daemonset is deleted, all related pods are deleted.

One excellent case to use a daemonset is a daemon to grab Logs from Nodes (e.g. fluentd, logstash or a Splunk-Forwarder)

More information abount daemonsets can be found in the [Kubernetes DaemonSet Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/).
