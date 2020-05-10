---
title: "10.6 Sidecar"
weight: 106
---

Lets first check again what a Pod is, from [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/) on the Kubernetes documation page:

> A Pod (as in a pod of whales or pea pod) is a group of one or more containers (such as Docker containers), with shared storage/network, and a specification for how to run the containers. A Pod’s contents are always co-located and co-scheduled, and run in a shared context. A Pod models an application-specific “logical host” - it contains one or more application containers which are relatively tightly coupled — in a pre-container world, being executed on the same physical or virtual machine would mean being executed on the same logical host.

> The shared context of a Pod is a set of Linux namespaces, cgroups, and potentially other facets of isolation - the same things that isolate a Docker container. Within a Pod’s context, the individual applications may have further sub-isolations applied.

A sidecar is a utility container in the Pod and its purpose is to support the main container. It is important to note that standalone sidecar does not serve any purpose, it must be paired with one or more main containers. Generally, sidecar container is reusable and can be paired with numerous type of main containers.

In a sidecar pattern, the functionality of the main container is extended or enhanced by a sidecar container without strong coupling between two. Although it is always possible to build sidecar container functionality into the main container, there are several benefits with this pattern,

* different resource profiles i.e., independent resource accounting and allocation
* clear separation of concerns at packaging level i.e., no strong coupling between containers
* reusability i.e., sidecar containers can be paired with numerous different "main" containers
* failure containment boundary, making it possible for the overall system to degrade gracefully
* independent testing, packaging, upgrade, deployment and if necessary roll back

## Task: Add a Prometheus MySQL Exporter as Sidecar

We are going to add a the prometheus MySQL Exporter to our database from [Lab 8](.../08.0/).

Change the existing MySQL deployment using:

```bash
kubectl edit deployment mysql --namespace [NAMESPACE]
```

And add a new (sidecar) container into your Deployment:

```yaml
[...]
- env:
  - name: DATA_SOURCE_NAME
    value: root:$MYSQL_ROOT_PASSWORD@(localhost:3306)/
  - name: MYSQL_ROOT_PASSWORD
    valueFrom:
      secretKeyRef:
        key: password
        name: mysql-root-password
  image: prom/mysqld-exporter
  name: mysqld-exporter
[...]
```

Your Pod does now have two running container. Verify this with:

```bash
kubectl get pod --namespace [NAMESPACE]
```

The output should look similar to this.

```
NAME                     READY   STATUS    RESTARTS   AGE
mysql-65559644c9-cdjjk   2/2     Running   0          5m35s
```

Note the `Ready` column which show you 2 ready container.

You can observe the logs from the mysqld-exporter with:

```bash
kubectl logs mysql-65559644c9-cdjjk -c mysqld-exporter
```

which gives you an output similar to this:

```
time="2020-05-10T11:31:02Z" level=info msg="Starting mysqld_exporter (version=0.12.1, branch=HEAD, revision=48667bf7c3b438b5e93b259f3d17b70a7c9aff96)" source="mysqld_exporter.go:257"
time="2020-05-10T11:31:02Z" level=info msg="Build context (go=go1.12.7, user=root@0b3e56a7bc0a, date=20190729-12:35:58)" source="mysqld_exporter.go:258"
time="2020-05-10T11:31:02Z" level=info msg="Enabled scrapers:" source="mysqld_exporter.go:269"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.global_variables" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.slave_status" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.global_status" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.info_schema.query_response_time" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.info_schema.innodb_cmp" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg=" --collect.info_schema.innodb_cmpmem" source="mysqld_exporter.go:273"
time="2020-05-10T11:31:02Z" level=info msg="Listening on :9104" source="mysqld_exporter.go:283"
```


and by using `kubectl port-forward ...` you can even have a look at the prometheus metrics using your browser:

```bash
kubectl port-forward mysql-65559644c9-cdjjk 9104
```

And the open http://localhost:9104/metrics in your browser.